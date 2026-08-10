# Use bash with strict error handling for all recipes.
# -e: exit on first error
# -u: treat undefined variables as errors
# -o pipefail: a pipe fails if any command in it fails
set shell := ["/usr/bin/env", "bash", "-eu", "-o", "pipefail", "-c"]

# Go module settings
export GO111MODULE := "on"  # Always use Go modules (not GOPATH mode)
export CGO_ENABLED := "0"   # Disable C interop for reproducible static binaries

# Load a local .env file if it exists (for local overrides, never committed)
set dotenv-load

# ── Dependencies ───────────────────────────────────────────────────────────────

# Download and tidy Go module dependencies
deps:
    go mod tidy
    go mod download

# ── Code Quality ───────────────────────────────────────────────────────────────

# Format source code
# gofmt: standard Go formatter (built-in)
# goimports: like gofmt but also organises import statements
fmt:
    gofmt -w .
    goimports -w .

# Check formatting without modifying files (used in CI)
fmt-check:
    @test -z "$(gofmt -l .)" || (echo "ERROR: The following files are not formatted:" && gofmt -l . && exit 1)

# Run the linter
lint:
    golangci-lint run ./...

# ── Testing ────────────────────────────────────────────────────────────────────

# Run all tests
# -count=1: disable test result caching (always run fresh)
# -race:    enable the race condition detector
# -v:       verbose output (print each test name and result)
test *ARGS="":
    go test -count=1 -race -v ./... {{ ARGS }}

# Run tests and produce an HTML coverage report
test-coverage:
    go test -race -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html
    @echo "Coverage report written to coverage.html"

# ── Build ──────────────────────────────────────────────────────────────────────

# Compile the application binary
# -ldflags="-s -w": strip debug info and symbol table (smaller binary)
build:
    go build -ldflags="-s -w" -o bin/api ./cmd/api

# Run the application locally
run:
    go run ./cmd/api

# ── Workflow ───────────────────────────────────────────────────────────────────

# Run before every commit: format, lint, and test
# If any step fails, the chain stops immediately
precommit: fmt lint test

# Remove all build artifacts and caches
clean:
    rm -rf bin/
    rm -f coverage.out coverage.html
    go clean -cache -testcache

# ── Tools ──────────────────────────────────────────────────────────────────────

# Install development tools (run once after cloning)
install-tools:
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install golang.org/x/tools/cmd/goimports@latest
