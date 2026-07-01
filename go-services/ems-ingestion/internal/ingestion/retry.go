package ingestion

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"ems-ingestion/internal/config"

	"github.com/redis/go-redis/v9"
)

type RetryPayload struct {
	SinkID  int64         `json:"sinkId"`
	Message DeviceMessage `json:"message"`
	Attempt int           `json:"attempt"`
	Error   string        `json:"error"`
}

type RetryWorker struct {
	cfg       config.Config
	redis     *redis.Client
	processor *Processor
}

func NewRetryWorker(cfg config.Config, redisClient *redis.Client, processor *Processor) *RetryWorker {
	return &RetryWorker{cfg: cfg, redis: redisClient, processor: processor}
}

func EnqueueRetry(ctx context.Context, redisClient *redis.Client, stream string, payload RetryPayload) error {
	body, _ := json.Marshal(payload)
	return redisClient.XAdd(ctx, &redis.XAddArgs{
		Stream: stream,
		Values: map[string]any{"payload": string(body)},
	}).Err()
}

func (w *RetryWorker) Start(ctx context.Context) {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			w.claimPending(ctx)
			w.readNew(ctx)
		}
	}
}

func (w *RetryWorker) readNew(ctx context.Context) {
	streams, err := w.redis.XReadGroup(ctx, &redis.XReadGroupArgs{
		Group:    w.cfg.RetryGroup,
		Consumer: w.cfg.RetryConsumer,
		Streams:  []string{w.cfg.RetryStream, ">"},
		Count:    10,
		Block:    time.Second,
	}).Result()
	if err != nil && err != redis.Nil {
		log.Printf("retry read failed: %v", err)
		return
	}
	w.handleStreams(ctx, streams)
}

func (w *RetryWorker) claimPending(ctx context.Context) {
	pending, err := w.redis.XPendingExt(ctx, &redis.XPendingExtArgs{
		Stream: w.cfg.RetryStream,
		Group:  w.cfg.RetryGroup,
		Start:  "-",
		End:    "+",
		Count:  20,
	}).Result()
	if err != nil {
		return
	}
	for _, item := range pending {
		if item.Idle < 30*time.Second {
			continue
		}
		claimed, err := w.redis.XClaim(ctx, &redis.XClaimArgs{
			Stream:   w.cfg.RetryStream,
			Group:    w.cfg.RetryGroup,
			Consumer: w.cfg.RetryConsumer,
			MinIdle:  30 * time.Second,
			Messages: []string{item.ID},
		}).Result()
		if err != nil {
			continue
		}
		w.handleMessages(ctx, claimed)
	}
}

func (w *RetryWorker) handleStreams(ctx context.Context, streams []redis.XStream) {
	for _, stream := range streams {
		w.handleMessages(ctx, stream.Messages)
	}
}

func (w *RetryWorker) handleMessages(ctx context.Context, messages []redis.XMessage) {
	for _, item := range messages {
		raw, _ := item.Values["payload"].(string)
		var payload RetryPayload
		if err := json.Unmarshal([]byte(raw), &payload); err != nil {
			_ = w.redis.XAck(ctx, w.cfg.RetryStream, w.cfg.RetryGroup, item.ID).Err()
			continue
		}
		snapshot := w.processor.deps.Cache.Snapshot()
		sink, ok := snapshot.DataSinks[payload.SinkID]
		if !ok {
			_ = w.redis.XAck(ctx, w.cfg.RetryStream, w.cfg.RetryGroup, item.ID).Err()
			continue
		}
		if err := w.processor.deps.Sinks.Execute(ctx, sink, payload.Message); err != nil {
			payload.Attempt++
			payload.Error = err.Error()
			if payload.Attempt > w.cfg.RetryMaxAttempt {
				_ = w.redis.XAdd(ctx, &redis.XAddArgs{
					Stream: w.cfg.RetryStream + ":dead",
					Values: map[string]any{"payload": raw, "error": err.Error()},
				}).Err()
				_ = w.redis.XAck(ctx, w.cfg.RetryStream, w.cfg.RetryGroup, item.ID).Err()
				continue
			}
			_ = EnqueueRetry(ctx, w.redis, w.cfg.RetryStream, payload)
			_ = w.redis.XAck(ctx, w.cfg.RetryStream, w.cfg.RetryGroup, item.ID).Err()
			continue
		}
		_ = w.redis.XAck(ctx, w.cfg.RetryStream, w.cfg.RetryGroup, item.ID).Err()
	}
}
