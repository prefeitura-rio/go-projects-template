// Package observability centralises logging and, in the future, metrics.
// Structured logging with log/slog is the org standard: use the returned
// logger instead of the global log package so fields stay structured.
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

// NewLogger returns a structured logger configured from the LOG_LEVEL
// environment variable (debug, info, warn, error; default: info).
// For template simplicity the level is read here directly; in a real project
// prefer passing the parsed level from the config package.
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

// WithLogger stores the logger in ctx so downstream layers can retrieve it
// without passing it through every function signature.
func WithLogger(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, loggerKey, logger)
}

// LoggerFromContext returns the logger stored in ctx, falling back to the
// default logger when none was stored.
func LoggerFromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(loggerKey).(*slog.Logger); ok {
		return logger
	}
	return slog.Default()
}

// WithTraceID stores the request trace ID in ctx for correlation across logs.
func WithTraceID(ctx context.Context, traceID string) context.Context {
	return context.WithValue(ctx, traceIDKey, traceID)
}

// TraceIDFromContext returns the trace ID stored in ctx, or "" when absent.
func TraceIDFromContext(ctx context.Context) string {
	if traceID, ok := ctx.Value(traceIDKey).(string); ok {
		return traceID
	}
	return ""
}

// WithTraceIDField returns a logger annotated with the ctx trace ID, so every
// log line emitted by downstream code carries the request correlation ID.
func WithTraceIDField(ctx context.Context, logger *slog.Logger) *slog.Logger {
	if traceID := TraceIDFromContext(ctx); traceID != "" {
		return logger.With("trace_id", traceID)
	}
	return logger
}
