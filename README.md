# Go Project Template

A minimal, production-ready template for Go projects.

## Stack

- **Language**: Go 1.24
- **HTTP**: standard library `net/http`
- **Linting**: golangci-lint
- **Dev environment**: devenv (Nix-based)
- **Task runner**: Just

## Project Structure

```
.
├── cmd/
│   └── api/          # Application entry point
├── internal/
│   └── health/       # Health check handler and tests
├── configs/          # Configuration files
├── scripts/          # Helper scripts
└── .github/
    └── workflows/    # CI/CD pipelines
```

## Prerequisites

- [devenv](https://devenv.sh) — manages Go, tools, and environment variables
- [Just](https://github.com/casey/just) — task runner (installed via devenv)

## Getting Started

```bash
# Enter the development environment
devenv shell

# Install Go module dependencies
just deps

# Run the application
just run

# Run tests
just test

# Run linter
just lint
```

## Available Commands

| Command | Description |
|---|---|
| `just deps` | Download Go module dependencies |
| `just fmt` | Format code |
| `just lint` | Run linter |
| `just test` | Run tests |
| `just test-coverage` | Run tests with coverage report |
| `just build` | Build the binary |
| `just run` | Run the application locally |
| `just precommit` | Run fmt + lint + test (run before committing) |
| `just clean` | Remove build artifacts |

## CI/CD

GitHub Actions runs automatically on every push and pull request to `main`:

1. **Format check** — verifies code is correctly formatted
2. **Lint** — runs golangci-lint with project rules
3. **Test** — runs all tests with race detection

## Customizing This Template

1. Update the module name in `go.mod`
2. Update the module path references in import statements
3. Replace the `health` package with your own domain logic
4. Update environment variables in `devenv.nix`
