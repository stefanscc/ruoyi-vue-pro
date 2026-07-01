package app

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"ems-ingestion/internal/config"
	"ems-ingestion/internal/ingestion"
)

func Run(ctx context.Context, cfg config.Config) error {
	deps, err := ingestion.NewDependencies(ctx, cfg)
	if err != nil {
		return err
	}
	defer deps.Close()

	if err := deps.Cache.Reload(ctx); err != nil {
		return err
	}
	if err := deps.TD.EnsureMessageStable(ctx); err != nil {
		return err
	}
	if err := deps.TD.EnsureProductPropertyTables(ctx, deps.Cache.Snapshot()); err != nil {
		return err
	}

	processor := ingestion.NewProcessor(cfg, deps)
	api := ingestion.NewHTTPServer(cfg, deps, processor)
	mqttClient := ingestion.NewMQTTClient(cfg, processor)

	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           api,
		ReadHeaderTimeout: 10 * time.Second,
	}

	errCh := make(chan error, 3)
	go func() {
		log.Printf("HTTP server listening on %s", cfg.HTTPAddr)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()
	go func() {
		errCh <- mqttClient.Start(ctx)
	}()
	go deps.Cache.StartAutoReload(ctx, cfg.CacheReloadInterval, deps.TD)
	go deps.StartRetryWorker(ctx, processor)

	select {
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer cancel()
		_ = server.Shutdown(shutdownCtx)
		mqttClient.Stop()
		return nil
	case err := <-errCh:
		return err
	}
}
