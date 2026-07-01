package ingestion

import (
	"context"
	"log"

	"ems-ingestion/internal/config"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

type Dependencies struct {
	Cfg   config.Config
	PG    *pgxpool.Pool
	Redis *redis.Client
	TD    *TDengineClient
	Cache *ConfigCache
	Sinks *DatabaseSinkExecutor
}

func NewDependencies(ctx context.Context, cfg config.Config) (*Dependencies, error) {
	pg, err := pgxpool.New(ctx, cfg.PostgresDSN)
	if err != nil {
		return nil, err
	}
	if err := pg.Ping(ctx); err != nil {
		pg.Close()
		return nil, err
	}
	redisClient := redis.NewClient(&redis.Options{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
		DB:       cfg.RedisDB,
	})
	if err := redisClient.Ping(ctx).Err(); err != nil {
		pg.Close()
		_ = redisClient.Close()
		return nil, err
	}
	td := NewTDengineClient(cfg)
	cache := NewConfigCache(pg)
	return &Dependencies{
		Cfg:   cfg,
		PG:    pg,
		Redis: redisClient,
		TD:    td,
		Cache: cache,
		Sinks: NewDatabaseSinkExecutor(cfg.DatabaseSinkHostOverride),
	}, nil
}

func (d *Dependencies) Close() {
	if d.Sinks != nil {
		d.Sinks.Close()
	}
	if d.Redis != nil {
		_ = d.Redis.Close()
	}
	if d.PG != nil {
		d.PG.Close()
	}
}

func (d *Dependencies) StartRetryWorker(ctx context.Context, processor *Processor) {
	if err := d.Redis.XGroupCreateMkStream(ctx, d.Cfg.RetryStream, d.Cfg.RetryGroup, "0").Err(); err != nil {
		log.Printf("retry stream group init skipped: %v", err)
	}
	worker := NewRetryWorker(d.Cfg, d.Redis, processor)
	worker.Start(ctx)
}
