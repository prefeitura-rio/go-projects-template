{ pkgs, ... }:

{
  name = "go-api-template";

  languages.go.enable = true;

  packages = [ pkgs.gofumpt pkgs.gotools pkgs.golangci-lint pkgs.ast-grep ];

  tasks = {
    "app:format" = {
      exec = "gofumpt -w . && goimports -w .";
    };

    "app:format:check" = {
      exec = ''
        set -euo pipefail
        UNFORMATTED=$(gofumpt -l .)
        if [ -n "$UNFORMATTED" ]; then echo "$UNFORMATTED"; exit 1; fi
        UNFORMATTED=$(goimports -l .)
        if [ -n "$UNFORMATTED" ]; then echo "$UNFORMATTED"; exit 1; fi
      '';
    };

    "app:lint" = {
      exec = "golangci-lint run --fix";
    };

    "app:lint:check" = {
      exec = "golangci-lint run";
    };

    "app:strlint" = {
      exec = "ast-grep scan --config .quality-gate/sgconfig.yaml";
    };

    "app:strlint:check" = {
      exec = "ast-grep scan --config .quality-gate/sgconfig.yaml";
    };

    "app:typecheck" = {
      exec = ''
        set -e
        go vet ./...
        if [ -d cmd ]; then go build -o /dev/null ./cmd/...; else go build -o /dev/null .; fi
      '';
    };

    "app:test" = {
      exec = "CGO_ENABLED=1 go test -count=1 -race -v ./...";
    };
  };

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };

    app-format = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-format" ''
        echo "[pre-commit] app:format:check — checking formatting..."
        if ! devenv tasks run app:format:check > /dev/null 2>&1; then
          echo "[pre-commit] app:format — formatting issues found, auto-fixing..."
          devenv tasks run app:format
          git add -u
          echo "[pre-commit] app:format — files auto-formatted and re-staged."
          echo "[pre-commit] Review changes with: git diff --cached"
          echo "[pre-commit] Then commit again to proceed."
          exit 1
        fi
        echo "[pre-commit] app:format:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-lint = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-lint" ''
        echo "[pre-commit] app:lint:check — running lint checks..."
        if ! devenv tasks run app:lint:check > /dev/null 2>&1; then
          echo "[pre-commit] app:lint — lint issues found, attempting auto-fix..."
          devenv tasks run app:lint
          git add -u
          echo "[pre-commit] app:lint — auto-fix applied and re-staged."
          echo "[pre-commit] Review changes with: git diff --cached"
          echo "[pre-commit] Then commit again to proceed."
          exit 1
        fi
        echo "[pre-commit] app:lint:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-strlint = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-strlint" ''
        echo "[pre-commit] app:strlint:check — running structural lint..."
        if ! devenv tasks run app:strlint:check > /dev/null 2>&1; then
          echo "[pre-commit] app:strlint:check — failed. Fix violations above."
          exit 1
        fi
        echo "[pre-commit] app:strlint:check — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-commit" ];
    };

    app-typecheck = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-typecheck" ''
        echo "[pre-push] app:typecheck — running type checks..."
        if ! devenv tasks run app:typecheck; then
          echo "[pre-push] app:typecheck — failed."
          exit 1
        fi
        echo "[pre-push] app:typecheck — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-push" ];
    };

    app-test = {
      enable = true;
      entry = "${pkgs.writeShellScript "app-test" ''
        echo "[pre-push] app:test — running tests..."
        if ! devenv tasks run app:test; then
          echo "[pre-push] app:test — failed."
          exit 1
        fi
        echo "[pre-push] app:test — passed."
      ''}";
      language = "system";
      pass_filenames = false;
      stages = [ "pre-push" ];
    };
  };
}
