// Package handler provides HTTP handlers for the application.
package handler

import (
	"encoding/json"
	"net/http"
)

// HealthResponse is the JSON body returned by the health check endpoint.
type HealthResponse struct {
	Status string `json:"status"`
}

// Health returns an HTTP handler that responds with a JSON health status.
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
