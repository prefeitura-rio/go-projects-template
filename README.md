# Go Project Template

A minimal, production-ready template for Go projects.

## Stack

- **Language**: Go 1.26
- **HTTP**: standard library `net/http`
- **Dev environment**: devenv (Nix-based, reproducible)

## Project Structure

```
.
├── cmd/
│   └── api/                   # Application entry point
├── configs/                   # Configuration files
├── deployments/
│   └── compose/               # Docker Compose for local development
├── internal/
│   ├── app/                   # Application bootstrap and lifecycle
│   ├── config/                # Configuration structs and loading
│   ├── domain/                # Business entities
│   ├── http/
│   │   ├── handler/           # HTTP handlers
│   │   └── middleware/        # HTTP middleware
│   ├── observability/         # Logs, metrics, tracing
│   ├── repository/            # Persistence interfaces and implementations
│   ├── service/               # Business logic
│   └── version/               # Version information
├── k8s/
│   └── staging/               # Kubernetes manifests
├── migrations/                # Database migration files
├── pkg/                       # Reusable packages
├── scripts/                   # Helper scripts
└── .github/
    └── workflows/             # CI/CD pipelines
```

## Getting Started

The Go toolchain is declared in `devenv.nix`. You do not install it manually.
The bootstrap script installs the prerequisites and sets up automatic environment
activation in a single step.

### Step 1 — Bootstrap (one time, per machine)

```bash
git clone git@github.com:prefeitura-rio/go_projects_template.git
cd go_projects_template
bash scripts/bootstrap.sh
```

The script:

| What | Details |
|---|---|
| Installs Nix | Package manager that devenv is built on |
| Installs devenv | Reads `devenv.nix`; provides the Go toolchain |
| Adds devenv shell hook | One line in your shell RC file (`~/.bashrc`, `~/.zshrc`, etc.) that enables auto-activation on `cd` |

After the script finishes, open a **new terminal** so the shell hook takes effect.

### Step 2 — Trust the project (one time, per clone)

```bash
cd go_projects_template
devenv allow
```

This tells devenv it may activate automatically when you enter this directory.

### Step 3 — Work normally

From this point on, entering the project directory in any terminal automatically
activates the full environment — Go, git hooks — with no extra commands.

```bash
cd go_projects_template   # environment activates
go build ./...
go test ./...
```

Leaving the directory deactivates it automatically.

## Git Hooks

devenv automatically installs pre-commit hooks when the environment is activated.
These hooks run on every `git commit` before the commit is recorded:

| Hook | Behaviour |
|---|---|
| `ripsecrets` | Scans for accidentally committed secrets; aborts commit if found |
| `no-commit-to-branch` | Blocks direct commits to `main`; use a branch and open a PR |

## CI/CD

GitHub Actions runs automatically on every push and pull request to `main`.

Quality checks (formatting, linting, tests) are enforced by the quality gate action
(`prefeitura-rio/actions/quality-gate`), which is currently being developed.

## Customizing This Template

1. Update the module name in `go.mod`
2. Update the module path in all import statements
3. Replace the `health` package with your own domain logic
