# AGENTS.md

Guidance for coding agents working in this repository.

## Structure

This repository holds three independent Go project templates. Each one is
copied into a new repository root and initialized with its own bootstrap
script, so treat every directory as a separate project:

| Template | What it is | Module (placeholder) |
|---|---|---|
| `api/` | HTTP REST API (stdlib `net/http`) | `github.com/prefeitura-rio/go-projects-template` |
| `cli/` | Command-line tool (stdlib `flag`, testable `Run(args, out)`) | `github.com/prefeitura-rio/go-cli-template` |
| `library/` | Importable Go package | `github.com/prefeitura-rio/go-library-template` |

- Each template has its own `go.mod` (Go 1.26), `devenv.nix`, `.golangci.yml`,
  `.quality-gate/` (ast-grep rules), `.github/workflows/`, `README.md` and
  `AGENTS.md`. There is no Go module at the repository root: run every Go
  command from inside a template directory.
- A change to the shared conventions (lint config, ast-grep rules, devenv
  tasks, workflows) usually has to be applied to all three templates.

## Tests and type check

Run in each template you touched (`api`, `cli`, `library`):

```bash
cd <template>
go test -race ./...
go vet ./...
```

With devenv available, the same checks CI runs are:

```bash
cd <template>
devenv tasks run app:typecheck   # go vet + go build
devenv tasks run app:test        # CGO_ENABLED=1 go test -count=1 -race -v ./...
```

## Formatting and lint

The tools come from devenv (`devenv.nix` of each template); they are not
required to be installed globally.

```bash
cd <template>
devenv tasks run app:format:check   # gofumpt -l + goimports -l
devenv tasks run app:format         # gofumpt -w + goimports -w (auto-fix)
devenv tasks run app:lint:check     # golangci-lint run (.golangci.yml)
devenv tasks run app:lint           # golangci-lint run --fix
devenv tasks run app:strlint        # ast-grep scan --config .quality-gate/sgconfig.yaml
```

## CI

- `.github/workflows/quality-gate.yaml` at the repository root is the CI of
  this repository. It runs on every pull request to `main` and on push to
  `main`, as a matrix with the checks `<template> / app:format`,
  `<template> / app:lint`, `<template> / app:strlint` and
  `<template> / app:typecheck`, followed by `<template> / app:test`, through
  `prefeitura-rio/actions/quality-gate`.
- The workflows inside each template (`<template>/.github/workflows/`, including
  `api/.github/workflows/sast.yaml`) do not run here: they only run in the
  repository created from the template.

## Bootstrap

Keep `scripts/bootstrap.sh` of each template working. It rewrites the
placeholder module path, names and files (`go.mod`, imports, `devenv.nix`,
`cmd/mycli/` in `cli/`, `mylibrary.go` and `mylibrary_test.go` in `library/`).
When you rename or add a file, identifier or placeholder that the script
touches, update the script and its validations in the same change.
