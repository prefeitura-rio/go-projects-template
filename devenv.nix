# devenv.nix — Development environment for go_projects_template
#
# This file is read by `devenv shell`, which creates an isolated shell
# environment with the exact tools and versions declared here.
#
# Usage:
#   devenv shell        — enter the development environment
#   devenv tasks run app:lint   — run the linter
#   devenv tasks run app:fmt    — format code
#   devenv tasks run app:test   — run tests
#
# See https://devenv.sh for documentation.

{ pkgs, ... }:

{
  # Human-readable name for this environment (shown in shell prompt).
  name = "go_projects_template";

  # Automatically load a .env file from the project root when entering
  # the shell. The .env file is listed in .gitignore and never committed.
  dotenv.enable = true;

  # ── System packages ──────────────────────────────────────────────────────────
  # These are tools available in the shell PATH, managed by Nix.
  # They are NOT Go module dependencies — they are developer tools.
  packages = with pkgs; [
    # Task runner — provides the `just` command for running Justfile recipes
    just

    # Go linter (as specified in INFRAVPIA-229)
    golangci-lint

    # Go formatter — stricter superset of gofmt (as specified in INFRAVPIA-229)
    gofumpt

    # Import organiser — sorts and groups Go import statements
    gotools # includes goimports
  ];

  # ── Language runtime ─────────────────────────────────────────────────────────
  # devenv manages the Go toolchain. This ensures all developers and CI use
  # the same Go version without manual installation.
  languages.go = {
    enable = true;
    # Pin the Go version. Update this when the project upgrades Go.
    # Available packages: pkgs.go (latest), pkgs.go_1_23, pkgs.go_1_24, etc.
    package = pkgs.go_1_24;
  };

  # ── Git hooks ────────────────────────────────────────────────────────────────
  # These hooks run automatically before each `git commit`.
  # If any hook fails, the commit is aborted.
  #
  # devenv installs these hooks into .git/hooks/ when you enter the shell.
  # This means every developer gets the same hooks without manual setup.
  git-hooks.hooks = {

    # Scan for accidentally committed secrets (API keys, tokens, passwords).
    # Uses pattern matching — catches common secret formats.
    ripsecrets.enable = true;

    # Prevent direct commits to protected branches.
    # All changes to main must go through a Pull Request.
    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };

    # Auto-format with gofumpt before committing.
    # Uses -w (write) to reformat files in place.
    # If any file is changed, pre-commit detects the modification, aborts the
    # commit, and prompts the developer to review and re-stage the formatted
    # files. On the second commit attempt the hook finds nothing to change
    # and the commit succeeds.
    # This is preferable to just reporting: the hook fixes the problem rather
    # than asking the developer to run a separate command.
    gofumpt-format = {
      enable = true;
      name = "gofumpt";
      entry = "gofumpt -w .";
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };

    # Auto-organise imports with goimports before committing.
    # Same auto-fix pattern as gofumpt: rewrites files in place, aborts the
    # commit if any file was changed so the developer can review and re-stage.
    goimports-format = {
      enable = true;
      name = "goimports";
      entry = "goimports -w .";
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };

    # Lint check — runs golangci-lint before committing.
    # Uses the project's .golangci.yml configuration.
    golangci-lint-check = {
      enable = true;
      name = "golangci-lint";
      entry = "golangci-lint run --fix=false";
      # --fix=false: report issues but never auto-modify files in a hook
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };
  };

  # ── Tasks ────────────────────────────────────────────────────────────────────
  # Named tasks runnable with `devenv tasks run <name>`.
  # These mirror the Justfile recipes but are available inside the devenv
  # environment without requiring `just` to be called explicitly.
  #
  # Convention from INFRAVPIA-229 quality gate stages:
  tasks = {
    "app:fmt".exec  = "gofumpt -w . && goimports -w .";
    "app:lint".exec = "golangci-lint run ./...";
    "app:test".exec = "go test -count=1 -race -v ./...";
  };
}
