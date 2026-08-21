{ pkgs, ... }:

{
  name = "go-library-template";

  languages.go.enable = true;

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };
  };
}
