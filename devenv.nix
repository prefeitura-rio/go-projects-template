# devenv.nix — Development environment for go_projects_template
#
# Tool versions come from the nixpkgs snapshot pinned in devenv.lock.
# The command layer lives in the Justfile so local dev and CI share one
# entry point. See https://devenv.sh.

{ pkgs, ... }:

{
  name = "go_projects_template";

  packages = with pkgs; [
    just
    golangci-lint
    gofumpt
    gotools # includes goimports
    ast-grep # structural search and lint (sg)
  ];

  # Version is pinned via devenv.lock, not here. Only pin a specific version
  # when the project has a hard external requirement on it.
  languages.go.enable = true;

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };

    gofumpt-format = {
      enable = true;
      name = "gofumpt";
      entry = "gofumpt -w .";
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };

    goimports-format = {
      enable = true;
      name = "goimports";
      entry = "goimports -w .";
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };

    golangci-lint-check = {
      enable = true;
      name = "golangci-lint";
      entry = "golangci-lint run --fix=false";
      language = "system";
      types = [ "go" ];
      pass_filenames = false;
    };
  };
}
