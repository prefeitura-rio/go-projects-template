// Package handler provides HTTP handlers.
package handler

import (
	"encoding/json"
	"net/http"
)

// HealthResponse is the JSON health check response.
type HealthResponse struct {
	Status string `json:"status"`
}

// Health returns the health check handler.
func Health() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)

		resp := HealthResponse{Status: "ok"}
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			http.Error(w, "failed to encode response", http.StatusInternalServerError)
		}
	}
}
