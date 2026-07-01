package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"ems-ingestion/internal/app"
	"ems-ingestion/internal/config"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	cfg := config.Load()
	if err := app.Run(ctx, cfg); err != nil {
		log.Fatalf("ems-ingestion stopped: %v", err)
	}
}
