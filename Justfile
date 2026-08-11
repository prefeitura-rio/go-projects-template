set shell := ["/usr/bin/env", "bash", "-eu", "-o", "pipefail", "-c"]

export GO111MODULE := "on"
export CGO_ENABLED := "0"

set dotenv-load

# ── Dependencies ──
deps:
    go mod tidy
    go mod download

# ── Code Quality ──
fmt:
    gofumpt -w .
    goimports -w .

# Check formatting without modifying files (used in CI)
fmt-check:
    @test -z "$(gofumpt -l .)" || (echo "ERROR: The following files are not formatted (gofumpt):" && gofumpt -l . && exit 1)
    @test -z "$(goimports -l .)" || (echo "ERROR: The following files have unorganised imports (goimports):" && goimports -l . && exit 1)

lint:
    golangci-lint run ./...

# ── ast-grep (structural lint) ──
# Scan the codebase with custom ast-grep rules in rules/
sg-lint:
    ast-grep scan

# Test that the ast-grep rules behave as expected (tests/)
sg-test *ARGS="":
    ast-grep test -t tests {{ ARGS }}

# ── Testing ──
# -race requires CGO_ENABLED=1 (file-level default is 0 for static builds)
test *ARGS="":
    CGO_ENABLED=1 go test -count=1 -race -v ./... {{ ARGS }}

test-coverage:
    CGO_ENABLED=1 go test -race -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html
    @echo "Coverage report written to coverage.html"

# ── Build ──
# -ldflags="-s -w": strip debug info for a smaller binary
build:
    go build -ldflags="-s -w" -o bin/api ./cmd/api

run:
    go run ./cmd/api

# ── Workflow ──
precommit: fmt lint sg-lint sg-test test

clean:
    rm -rf bin/
    rm -f coverage.out coverage.html
    go clean -cache -testcache
