// Package service implements the application's business logic. Services
// depend only on the domain interfaces — never on concrete repositories —
// which keeps every layer testable in isolation.
package service

import (
	"context"

	"github.com/prefeitura-rio/go-projects-template/internal/domain"
)

// HealthService provides the application's health-check business logic.
type HealthService struct {
	repo domain.HealthRepository
}

// NewHealthService creates a health service backed by the given repository.
func NewHealthService(repo domain.HealthRepository) *HealthService {
	return &HealthService{repo: repo}
}

// Get returns the current application health status.
func (s *HealthService) Get(ctx context.Context) (*domain.HealthStatus, error) {
	return s.repo.Get(ctx)
}
