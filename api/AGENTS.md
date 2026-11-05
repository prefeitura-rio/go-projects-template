# AGENTS.md

Guidance for coding agents working in this project.

## Project

HTTP REST API built on the standard library `net/http`. Entry point in
`cmd/`, application code in `internal/`, reusable packages in `pkg/`.

- Go 1.26 (`go.mod`). The toolchain and every tool below come from devenv
  (`devenv.nix`); they are not required to be installed globally.
- If `go.mod` still has the template module path, run
  `bash scripts/bootstrap.sh` once to initialize the project.

## Build, type check and tests

```bash
devenv tasks run app:typecheck   # go vet ./... + go build
devenv tasks run app:test        # CGO_ENABLED=1 go test -count=1 -race -v ./...
```

Without devenv, the equivalent commands are `go vet ./...` and
`go test -race ./...`.

## Formatting and lint

```bash
devenv tasks run app:format:check   # gofumpt -l + goimports -l
devenv tasks run app:format         # gofumpt -w + goimports -w (auto-fix)
devenv tasks run app:lint:check     # golangci-lint run (.golangci.yml)
devenv tasks run app:lint           # golangci-lint run --fix
devenv tasks run app:strlint        # ast-grep scan (.quality-gate/sgconfig.yaml)
```

The git hooks installed by devenv run format, lint and strlint on commit and
typecheck and test on push.

## CI

`.github/workflows/quality-gate.yaml` runs on every pull request and push to
`main`: the jobs Format, Lint, Structural Lint and Type Check in parallel,
then Test, through `prefeitura-rio/actions/quality-gate`.
`.github/workflows/sast.yaml` runs security scanning through
`prefeitura-rio/actions/.github/workflows/sast.yml` and needs the secrets and
variables listed in `README.md`.
