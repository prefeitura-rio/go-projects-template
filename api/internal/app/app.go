// Package app provides the application factory and server lifecycle.
package app

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/prefeitura-rio/go-projects-template/internal/http/handler"
)

// App holds the configured HTTP server.
type App struct {
	server *http.Server
}

func New(port string) *App {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", handler.Health())

	return &App{
		server: &http.Server{
			Addr:              fmt.Sprintf(":%s", port),
			Handler:           mux,
			ReadHeaderTimeout: 10 * time.Second,
			ReadTimeout:       30 * time.Second,
			WriteTimeout:      30 * time.Second,
		},
	}
}

// Handler exposes the application's HTTP handler.
func (a *App) Handler() http.Handler {
	return a.server.Handler
}

// Run starts the HTTP server and shuts it down when ctx is cancelled.
func (a *App) Run(ctx context.Context) error {
	errCh := make(chan error, 1)
	go func() {
		slog.Info("server starting", "addr", a.server.Addr)
		if err := a.server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
			return
		}
		errCh <- nil
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
	}

	slog.Info("shutting down server")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	return a.server.Shutdown(shutdownCtx)
}
