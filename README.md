# Go Project Template

A minimal, production-ready template for Go projects.

## Stack

- **Language**: Go 1.24
- **HTTP**: standard library `net/http`
- **Linting**: golangci-lint
- **Formatting**: gofumpt + goimports
- **Dev environment**: devenv (Nix-based, reproducible)
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

- [devenv](https://devenv.sh) — installs Go, all tools, and git hooks automatically
- [direnv](https://direnv.net) — activates the devenv environment when entering the directory (recommended)

All other tools (Go, just, golangci-lint, gofumpt, goimports) are managed by devenv.
You do not need to install them manually.

## Getting Started

### With direnv (recommended)

```bash
git clone git@github.com:prefeitura-rio/go_projects_template.git
cd go_projects_template
direnv allow    # one-time: grants direnv permission to auto-activate this environment
```

From this point on, entering the project directory in any terminal automatically
activates the environment, installs tools, and registers git hooks.

### Without direnv

```bash
git clone git@github.com:prefeitura-rio/go_projects_template.git
cd go_projects_template
devenv shell    # activate the environment manually in each terminal session
```

## Git Hooks

devenv automatically installs pre-commit hooks when the environment is activated.
These hooks run on every `git commit` before the commit is recorded:

| Hook | Behaviour |
|---|---|
| `gofumpt` | Auto-formats code in place; aborts commit if files were changed (re-stage and retry) |
| `goimports` | Auto-organises imports in place; same behaviour as gofumpt |
| `golangci-lint` | Reports lint violations; aborts commit — fix manually and retry |
| `ripsecrets` | Scans for accidentally committed secrets; aborts commit if found |
| `no-commit-to-branch` | Blocks direct commits to `main`; use a branch and open a PR |

## Available Commands

| Command | Description |
|---|---|
| `just deps` | Download Go module dependencies |
| `just fmt` | Format code (gofumpt + goimports) |
| `just fmt-check` | Check formatting without modifying files (used in CI) |
| `just lint` | Run linter |
| `just test` | Run all tests with race detection |
| `just test-coverage` | Run tests and produce an HTML coverage report |
| `just build` | Build the binary |
| `just run` | Run the application locally |
| `just precommit` | Run fmt + lint + test (mirrors CI quality gate) |
| `just clean` | Remove build artifacts |

## CI/CD

GitHub Actions runs automatically on every push and pull request to `main`.

```
      ┌─── fmt ───┐
CI ───┤            ├─── test
      └─── lint ──┘
```

- `fmt` and `lint` run in parallel
- `test` runs only after both pass
- All steps use the same commands as local development (`just`)

## Customizing This Template

1. Update the module name in `go.mod`
2. Update the module path in all import statements
3. Replace the `health` package with your own domain logic
4. Add environment variables to `devenv.nix` under the `env` section
5. Update tool versions in `Justfile` (`install-tools`) and `devenv.nix` (`packages`)
