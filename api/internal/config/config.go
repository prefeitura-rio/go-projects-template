// Package config loads application configuration from environment variables.
package config

import (
	"fmt"
	"os"
)

// Config holds the application configuration.
type Config struct {
	Port     string
	LogLevel string
}

// Load reads configuration from environment variables.
func Load() (*Config, error) {
	cfg := &Config{
		Port:     envOr("PORT", "8080"),
		LogLevel: envOr("LOG_LEVEL", "info"),
	}

	switch cfg.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		return nil, fmt.Errorf("invalid LOG_LEVEL %q: want debug, info, warn or error", cfg.LogLevel)
	}

	return cfg, nil
}

func envOr(name, def string) string {
	if v := os.Getenv(name); v != "" {
		return v
	}
	return def
}
