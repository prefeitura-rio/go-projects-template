// Package config loads the application configuration from environment
// variables. Secrets must never be hard-coded here; read them from the
// environment instead (see the .env ignore rules in .gitignore).
package config

import (
	"fmt"
	"os"
)

// Config holds the application configuration.
type Config struct {
	// Port is the TCP port the HTTP server listens on.
	Port string
	// LogLevel is the structured logger level: debug, info, warn or error.
	LogLevel string
}

// Load reads the configuration from environment variables, applying defaults
// when a variable is not set.
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

// envOr returns the value of the environment variable name, or def when the
// variable is unset or empty.
func envOr(name, def string) string {
	if v := os.Getenv(name); v != "" {
		return v
	}
	return def
}
