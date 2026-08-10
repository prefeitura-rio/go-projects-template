package health_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/prefeitura-rio/go_api_gin_template/internal/health"
)

func TestHandler_ReturnsOK(t *testing.T) {
	// Create a fake HTTP request targeting the health endpoint.
	req := httptest.NewRequest(http.MethodGet, "/health", nil)

	// Create a response recorder that captures what the handler writes.
	rec := httptest.NewRecorder()

	// Call the handler directly — no real server needed.
	health.Handler()(rec, req)

	// Assert the HTTP status code is 200.
	if rec.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", rec.Code)
	}

	// Assert the response body contains the expected JSON.
	var resp health.Response
	if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
		t.Fatalf("failed to decode response body: %v", err)
	}

	if resp.Status != "ok" {
		t.Errorf("expected status 'ok', got %q", resp.Status)
	}
}
