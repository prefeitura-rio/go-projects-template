// Package observability provides structured logging helpers.
package observability

import (
	"context"
	"log/slog"
	"os"
	"strings"
)

type contextKey string

const (
	loggerKey  contextKey = "logger"
	traceIDKey contextKey = "trace_id"
)

// NewLogger returns a logger configured from LOG_LEVEL.
func NewLogger() *slog.Logger {
	level := slog.LevelInfo
	switch strings.ToLower(os.Getenv("LOG_LEVEL")) {
	case "debug":
		level = slog.LevelDebug
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	}

	handler := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: level})
	return slog.New(handler)
}

// WithLogger stores a logger in ctx.
func WithLogger(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, loggerKey, logger)
}

// LoggerFromContext returns the logger stored in ctx.
func LoggerFromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(loggerKey).(*slog.Logger); ok {
		return logger
	}
	return slog.Default()
}

// WithTraceID stores a request trace ID in ctx.
func WithTraceID(ctx context.Context, traceID string) context.Context {
	return context.WithValue(ctx, traceIDKey, traceID)
}

// TraceIDFromContext returns the trace ID stored in ctx.
func TraceIDFromContext(ctx context.Context) string {
	if traceID, ok := ctx.Value(traceIDKey).(string); ok {
		return traceID
	}
	return ""
}

// WithTraceIDField adds the ctx trace ID to the logger.
func WithTraceIDField(ctx context.Context, logger *slog.Logger) *slog.Logger {
	if traceID := TraceIDFromContext(ctx); traceID != "" {
		return logger.With("trace_id", traceID)
	}
	return logger
}
