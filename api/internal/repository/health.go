// Package repository provides domain repository implementations.
package repository

import (
	"context"

	"github.com/prefeitura-rio/go-projects-template/internal/domain"
)

// InMemoryHealthRepository implements domain.HealthRepository.
type InMemoryHealthRepository struct{}

// NewInMemoryHealthRepository creates an in-memory health repository.
func NewInMemoryHealthRepository() *InMemoryHealthRepository {
	return &InMemoryHealthRepository{}
}

func (r *InMemoryHealthRepository) Get(ctx context.Context) (*domain.HealthStatus, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	return &domain.HealthStatus{Status: "ok"}, nil
}
