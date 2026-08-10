// Package health provides an HTTP handler for health check endpoints.
package health

import (
	"encoding/json"
	"net/http"
)

// Response is the JSON body returned by the health check endpoint.
type Response struct {
	Status string `json:"status"`
}

// Handler returns an HTTP handler that responds with a JSON health status.
func Handler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)

		resp := Response{Status: "ok"}
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			http.Error(w, "failed to encode response", http.StatusInternalServerError)
		}
	}
}
