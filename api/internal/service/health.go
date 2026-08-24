// Package service implements application business logic.
package service

import (
	"context"

	"github.com/prefeitura-rio/go-projects-template/internal/domain"
)

// HealthService provides health-check business logic.
type HealthService struct {
	repo domain.HealthRepository
}

// NewHealthService creates a health service.
func NewHealthService(repo domain.HealthRepository) *HealthService {
	return &HealthService{repo: repo}
}

func (s *HealthService) Get(ctx context.Context) (*domain.HealthStatus, error) {
	return s.repo.Get(ctx)
}
