// Command api starts the HTTP API server.
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/prefeitura-rio/go-projects-template/internal/app"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	if err := app.New(port).Run(ctx); err != nil {
		log.Fatalf("server error: %v", err)
	}
}