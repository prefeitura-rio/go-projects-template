// Package app provides the application factory: it wires the HTTP handlers
// and owns the server lifecycle. Application construction is separated from
// process startup so tests can exercise the full application without binding
// a real TCP port.
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

// New wires the mux and registers all handlers.
func New(port string) *App {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", handler.Health())

	return &App{
		server: &http.Server{
			Addr:    fmt.Sprintf(":%s", port),
			Handler: mux,
			// Timeouts protect against slow-loris style attacks and hung
			// connections; ReadHeaderTimeout is mandatory (gosec G112).
			ReadHeaderTimeout: 10 * time.Second,
			ReadTimeout:       30 * time.Second,
			WriteTimeout:      30 * time.Second,
		},
	}
}

// Handler exposes the application's HTTP handler, allowing tests to inject
// the handler without starting a real TCP server.
func (a *App) Handler() http.Handler {
	return a.server.Handler
}

// Run starts the HTTP server and blocks until ctx is cancelled or the server
// fails. On cancellation it performs a graceful shutdown.
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
