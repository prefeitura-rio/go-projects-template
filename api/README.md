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
go build ./...
go test ./...
```

```bash
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
