# Go API Template

A minimal, production-ready template for Go HTTP API services.

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

Copy this directory into a new, empty repository and run the bootstrap script:

```bash
cp -r go-projects-template/api/. my-new-api/
cd my-new-api
bash scripts/bootstrap.sh
```

The script prompts for the project name and Go module path, updates the module
and imports, installs the prerequisites, adds the devenv shell hook, and trusts
the project automatically. After it finishes, open a **new terminal**. The
environment activates automatically when you navigate to the project.

The Go toolchain is declared in `devenv.nix`; no manual Go installation is needed.

Verify the initialized project with:

```bash
devenv run app:typecheck
devenv run app:test
```

Leaving the directory deactivates it automatically.

## Running quality checks locally

devenv tasks wrap the same tools CI uses. Run them with `devenv run`:

```bash
devenv run app:format           # gofumpt + goimports (auto-fix)
devenv run app:format:check     # gofumpt + goimports (check)
devenv run app:lint             # golangci-lint --fix
devenv run app:lint:check       # golangci-lint
devenv run app:strlint          # ast-grep scan
devenv run app:typecheck        # go vet + go build
devenv run app:test             # go test -race
```

## Git Hooks

devenv automatically installs hooks when the environment is activated:

| Hook | Stage | Behaviour |
|---|---|---|
| `ripsecrets` | pre-commit | Scans for accidentally committed secrets |
| `no-commit-to-branch` | pre-commit | Blocks direct commits to `master` and `main` |
| `app-format` | pre-commit | Checks formatting (gofumpt + goimports); auto-fixes and re-stages, blocks commit |
| `app-lint` | pre-commit | Checks linting (golangci-lint); auto-fixes and re-stages, blocks commit |
| `app-strlint` | pre-commit | Structural lint (ast-grep); check-only, blocks commit |
| `app-typecheck` | pre-push | Runs `go vet` + `go build` |
| `app-test` | pre-push | Runs `go test -race` |

## CI/CD

GitHub Actions runs automatically on every push and pull request to `main`.
Two workflows ship with this template:

| Workflow | Purpose |
|---|---|
| `quality-gate.yaml` | Formatting, linting, structural lint, type check, tests — via `prefeitura-rio/actions/quality-gate` |
| `sast.yaml` | Security scanning (opengrep, grype/SBOM, checkov, SonarQube) via the org reusable workflow `prefeitura-rio/actions/.github/workflows/sast.yml` |

### SAST required secrets

`sast.yaml` needs the following secrets and variables at the repository or
organization level:

| Name | Type | Purpose |
|---|---|---|
| `SONAR_HOST_URL` | Variable | SonarQube server URL |
| `SONAR_TOKEN` | Secret | SonarQube access token |
| `DD_TOKEN` | Secret | DefectDojo API token |
| `TS_TAGS` | Secret | Tailscale tags for the runner |
| `TS_OAUTH_CLIENT_ID` | Secret | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Secret | Tailscale OAuth client secret |

Until these exist, the `sast` job will fail — configure them before enabling
the workflow.

## Customizing This Template

1. Update the module name in `go.mod`
2. Update the module path in all import statements
3. Replace the `health` package with your own domain logic
