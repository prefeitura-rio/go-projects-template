# Go Library Template

A minimal, production-ready template for publishable Go packages. Copy the
contents of this directory into a new repository root and start building.

## Stack

| Concern | Choice |
|---|---|
| Language | Go 1.26 |
| Distribution | Imported directly from the GitHub module path |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` |
| Tests | `go test` (race detector enabled) |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

## How Go libraries are distributed

Go has no central registry like PyPI or npm. A Go library is imported directly
from its version-control URL:

```bash
go get github.com/prefeitura-rio/my-library
```

The module path in `go.mod` **is** the distribution address. This is why the
module path matters more here than in an API or CLI template.

## Project structure

```
mylibrary.go        # Package mylibrary — the public API surface
mylibrary_test.go   # External test package (package mylibrary_test)
go.mod
devenv.nix
devenv.yaml
devenv.lock
scripts/bootstrap.sh
.github/workflows/quality-gate.yaml
```

Unlike the API and CLI templates, a library has:

- **no `cmd/` directory** — libraries have no entry point;
- **no `internal/` directory at the root** — `internal/` would prevent
  external consumers from importing those packages, which is the opposite of a
  library's purpose.

## Public API surface

The package at the module root is the single public entry point. Only
intended-public symbols may be exported:

- All exported symbols MUST have a doc comment starting with the symbol name.
- Keep the exported surface minimal — expose only what consumers should use.
- If you need sub-packages, place them at the root of the module (for example
  `github.com/prefeitura-rio/my-library/foo`). Their import paths must be
  intentional.

## How to use

1. Copy this directory into a new, empty repository:
   ```bash
   cp -r go-projects-template/library/. my-library/
   cd my-library
   ```
2. Rename the package:
   - Rename `mylibrary.go` to `<package_name>.go`.
   - Change the `package` clause to your package name.
   - Update `module` in `go.mod` to the target GitHub path.
   - Update the import in `mylibrary_test.go`.
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
after all four pass. For a library, `typecheck` compiles the module
(`go build ./...`) and runs `go vet ./...`.