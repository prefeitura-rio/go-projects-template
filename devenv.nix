# devenv.nix — Development environment for go-projects-template
#
# Provides the Go toolchain for local development. Tool versions are pinned
# by the nixpkgs snapshot in devenv.lock — never pin individual packages here.
#
# Quality checks (formatting, linting, tests) are owned by the CI quality gate
# action (prefeitura-rio/actions). See https://devenv.sh.

{ pkgs, ... }:

{
  name = "go-projects-template";

  # Version is pinned via devenv.lock, not here. Only pin a specific version
  # when the project has a hard external requirement on it.
  languages.go.enable = true;

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };
  };
}
