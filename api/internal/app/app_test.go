package app_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/prefeitura-rio/go-projects-template/internal/app"
)

func TestHandlerHealth(t *testing.T) {
	a := app.New("8080")

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	w := httptest.NewRecorder()

	a.Handler().ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected status %d, got %d", http.StatusOK, w.Code)
	}

	const wantBody = `{"status":"ok"}` + "\n"
	if got := w.Body.String(); got != wantBody {
		t.Fatalf("expected body %q, got %q", wantBody, got)
	}
}