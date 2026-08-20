// Package domain contains the core business entities and the interfaces the
// application depends on. It must stay free of framework and infrastructure
// concerns: no HTTP, no storage, no loggers — only pure types and contracts.
package domain

import "context"

// HealthStatus is the health-check entity returned by the application.
type HealthStatus struct {
	// Status describes the current state of the application (e.g. "ok").
	Status string
}

// HealthRepository is the contract the service layer depends on. Defining the
// interface next to the entity (consumer-side) lets us swap implementations
// (in-memory, PostgreSQL, ...) without touching callers.
type HealthRepository interface {
	// Get returns the current application health status.
	Get(ctx context.Context) (*HealthStatus, error)
}
