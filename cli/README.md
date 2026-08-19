# Go CLI Template

A minimal, production-ready template for Go command-line tools. Copy the
contents of this directory into a new repository root and start building.

## Stack

| Concern | Choice |
|---|---|
| Language | Go 1.26 |
| Argument parsing | standard library `flag` (no framework) |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` |
| Tests | `go test` (race detector enabled) |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@latest` |

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
.github/workflows/ci.yaml
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

1. Copy this directory into a new, empty repository:
   ```bash
   cp -r go-projects-template/cli/. my-cli/
   cd my-cli
   ```
2. Rename the command:
   - Rename `cmd/mycli/` to `cmd/<your_command>/`.
   - Update the module path in `go.mod`.
   - Update imports in `cmd/<your_command>/main.go` and
     `internal/cli/cli_test.go`.
   - Update the `FlagSet` name in `internal/cli/cli.go`.
   - Update `name` in `devenv.nix`.
3. Bootstrap the dev environment:
   ```bash
   bash scripts/bootstrap.sh
   # Open a new terminal, then:
   devenv allow
   ```
4. Verify everything works:
   ```bash
   go build ./...
   go test ./...
   ```

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