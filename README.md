# Go Project Templates

A collection of minimal, production-ready Go project starters. Each template
is an independent, self-contained repository — copy the contents of the
relevant subdirectory into a new repository root and start building.

## Available templates

| Template | Description | Highlights |
|---|---|---|
| [`api/`](./api/) | HTTP REST API | stdlib `net/http`, Go 1.26 |
| [`library/`](./library/) | Importable Go package | GitHub module path distribution |
| [`cli/`](./cli/) | Command-line tool | stdlib `flag`, testable `Run(args, out)` |

## What every template shares

All three templates use the same conventions so patterns learned in one apply
to the others:

| Concern | Choice |
|---|---|
| Language | Go 1.26 |
| HTTP | standard library `net/http` (API template) |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` + format/lint/strlint (pre-commit) + typecheck/test (pre-push) |
| Formatting | gofumpt + goimports |
| Linting | golangci-lint (org-wide config) |
| Structural linting | ast-grep (org-wide rules via `quality-gate`) |
| Tests | `go test` with race detector |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

## CI pipeline structure

Every template ships an identical `.github/workflows/quality-gate.yaml` with five jobs:

```
format ──┐
lint   ──┤
strlint──┼──> test
typecheck┘
```

The four checks run in parallel. `test` runs only after all four pass. This
keeps feedback fast: a formatting error does not block linting, and tests only
run on code that has already passed static analysis.

The `api/` template additionally ships `.github/workflows/sast.yaml` — security
scanning (opengrep, grype/SBOM, checkov, SonarQube) via the org reusable
workflow `prefeitura-rio/actions/.github/workflows/sast.yml`. See
[api/README.md](./api/README.md) for the required secrets and variables.

## Combining templates in one repository

If this template is placed under a subdirectory of a larger repository, its
nested `.github/workflows/` directory is not executed by GitHub. Define one
workflow at the repository root and call
`prefeitura-rio/actions/.github/workflows/quality-gate.yml@master` with an
explicit project name and `working-directory` for each project. Project names
are arbitrary; `api`, `library`, and `cli` are conventions, not an allowlist.
Because one Git repository has one effective hook set, combined repositories
must also define one root devenv configuration with project-qualified tasks;
nested template devenv shells must not compete to install hooks.

## How to use a template

Copy the desired template subdirectory into a new, empty repository and run its
bootstrap script. For example:

```bash
cp -r go-projects-template/api/. my-new-api/
cd my-new-api
bash scripts/bootstrap.sh
```

The script prompts for the values required by the selected template, performs
the renames and substitutions, installs the development environment, and trusts
the project automatically. Open a **new terminal** after the script finishes.

Follow the template-specific README for the prompts and verification commands.

## Template-specific docs

Each template contains its own `README.md` with detailed usage instructions,
stack choices, and testing guidance:

- [api/README.md](./api/README.md)
- [library/README.md](./library/README.md)
- [cli/README.md](./cli/README.md)
