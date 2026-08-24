# Go CLI Template

A minimal, production-ready template for Go command-line tools. Copy the
contents of this directory into a new repository root and start building.

## Stack

| Concern | Choice |
|---|---|
| Language | Go 1.26 |
| Argument parsing | standard library `flag` (no framework) |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` + format/lint/strlint (pre-commit) + typecheck/test (pre-push) |
| Tests | `go test` (race detector enabled) |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

## Project structure

```
cmd/
└── mycli/
    └── main.go            # Entry point: os.Args, os.Stdout, os.Exit
internal/
└── cli/
    ├── cli.go             # Run(args, out) — all command logic
    └── cli_test.go        # Tests using bytes.Buffer — no real IO
go.mod
devenv.nix
devenv.yaml
devenv.lock
scripts/bootstrap.sh
.github/workflows/quality-gate.yaml
```

## Why command logic lives in `internal/cli`

`cmd/mycli/main.go` is deliberately tiny. It only wires process-level
concerns to the rest of the program. All behaviour lives in `internal/cli`,
which exposes a single function:

```go
func Run(args []string, out io.Writer) error
```

This has two benefits:

- **Testability without subprocesses**: tests call `Run` directly with a
  `bytes.Buffer` instead of building the binary and executing it. The test
  never opens a real process, socket, or terminal.
- **Main stays dumb**: exit codes, `os.Args`, and `os.Stdout` are the only
  concerns in `main`. Error handling is delegated back to the caller.

## Why stdlib `flag` and not a framework

Popular CLI frameworks (cobra, urfave/cli) exist for a reason, but they pull
in dependencies and opinionated scaffolding. The template uses the standard
library `flag` package to keep the dependency surface at zero. This matches
the API template's "standard library `net/http`" decision.

If you need subcommands, autocompletion, or a rich help system, evaluate
adding `cobra` when your requirements demand it — not before.

## How to use

Copy this directory into a new, empty repository and run the bootstrap script:

```bash
cp -r go-projects-template/cli/. my-cli/
cd my-cli
bash scripts/bootstrap.sh
```

The script prompts for the command name and Go module path. It renames
`cmd/mycli/`, updates Go imports, updates the `FlagSet` name and doc comment,
installs the development environment, and trusts the project automatically.
Open a **new terminal** after the script finishes.

Verify everything works:

```bash
devenv run app:typecheck
devenv run app:test
```

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

## CI pipeline

Five jobs run on every push and pull request to `main`:

```
format ──┐
lint   ──┤
strlint──┼──> test
typecheck┘
```

`format`, `lint`, `strlint`, and `typecheck` run in parallel. `test` runs only
after all four pass. `typecheck` runs `go vet ./...` and builds the command
binary with `go build`.
