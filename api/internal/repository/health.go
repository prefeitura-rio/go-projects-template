// Package repository provides concrete implementations of the domain
// repository interfaces. This in-memory implementation is the default until a
// real persistence layer (e.g. PostgreSQL) is introduced.
package repository

import (
	"context"

	"github.com/prefeitura-rio/go-projects-template/internal/domain"
)

// InMemoryHealthRepository implements domain.HealthRepository and always
// reports a healthy application. It exists to demonstrate the pattern;
// replace it with a repository backed by real storage as needed.
type InMemoryHealthRepository struct{}

// NewInMemoryHealthRepository creates a new in-memory health repository.
func NewInMemoryHealthRepository() *InMemoryHealthRepository {
	return &InMemoryHealthRepository{}
}

// Get returns the current application health status.
func (r *InMemoryHealthRepository) Get(ctx context.Context) (*domain.HealthStatus, error) {
	// Honor context cancellation so long-running operations can be aborted.
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	return &domain.HealthStatus{Status: "ok"}, nil
}
