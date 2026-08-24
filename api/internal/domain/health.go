// Package domain contains core business entities and interfaces.
package domain

import "context"

// HealthStatus is the health-check entity.
type HealthStatus struct {
	Status string
}

// HealthRepository defines health status access.
type HealthRepository interface {
	Get(ctx context.Context) (*HealthStatus, error)
}
