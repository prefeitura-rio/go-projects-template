# Go Project Template

A minimal, production-ready template for Go projects.

## Stack

- **Language**: Go 1.26
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

## Getting Started

All tools — Go, golangci-lint, gofumpt, goimports, just — are declared in
`devenv.nix`. You do not install them manually. The bootstrap script installs
the only real prerequisite (Nix + devenv + direnv) in a single step.

### Step 1 — Bootstrap (one time, per machine)

```bash
git clone git@github.com:prefeitura-rio/go_projects_template.git
cd go_projects_template
bash scripts/bootstrap.sh
```

The script installs:

| Tool | Purpose |
|---|---|
| Nix | Package manager that devenv is built on |
| devenv | Reads `devenv.nix`; provides Go and all dev tools |
| direnv | Shell extension that auto-activates devenv when you enter the directory |

After the script finishes, open a **new terminal** so the shell changes take effect.

### Step 2 — Set up local environment variables (one time, per repo)

```bash
cp .env.example .env
```

`.env` is gitignored and is your local configuration file. Edit it to add
any project-specific values. devenv loads it automatically when the shell
activates, so you never need to `export` variables manually.

### Step 3 — Allow direnv (one time, per repo)

```bash
cd go_projects_template
direnv allow
```

This grants direnv permission to load `.envrc`. It only needs to be done once.
The environment will then activate automatically on every subsequent entry.

### Step 4 — Work normally

From this point on, entering the project directory in any terminal automatically
activates the full environment — Go, tools, and git hooks — with no extra commands.

```bash
cd go_projects_template   # environment activates
just test                 # run tests
just lint                 # run linter
```

### Without direnv

If you prefer not to use direnv, activate the environment manually each session:

```bash
cd go_projects_template
devenv shell
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

## Updating Tool Versions

All tool versions (Go, gopls, golangci-lint, gofumpt, etc.) are determined by
the nixpkgs snapshot pinned in `devenv.lock`. Every package in that snapshot is
internally consistent — Go and gopls, for example, are guaranteed to work
together because nixpkgs tested that exact combination.

To advance all tools to a newer snapshot:

```bash
devenv update          # rolls devenv.lock forward to a fresh consistent snapshot
go mod tidy            # align go.mod if the Go minor version changed
```

Then commit `devenv.lock` (and `go.mod` if it changed) like any other
dependency bump. Every developer who pulls that commit gets the exact same
new versions automatically on their next `direnv allow` reload.

**Why not pin individual package versions in `devenv.nix`?**

Writing `package = pkgs.go_1_25` adds a second constraint on top of
`devenv.lock`. If the pinned nixpkgs snapshot ships gopls built for Go 1.26,
forcing Go 1.25 breaks the build — as we experienced. The lock file is already
your reproducibility guarantee; individual pins fight it.

Only pin a specific package version when the project has a hard external
requirement on that exact version (e.g. a third-party SDK that doesn't yet
support the next Go release).

## Customizing This Template

1. Update the module name in `go.mod`
2. Update the module path in all import statements
3. Replace the `health` package with your own domain logic
4. Add environment variables to `devenv.nix` under the `env` section
5. Update tool versions in `Justfile` (`install-tools`) and `devenv.nix` (`packages`)
