#!/usr/bin/env bash

set -eu -o pipefail

step() {
  echo ""
  echo "===> $*"
}

ok() {
  echo "  [ok] $*"
}

note() {
  echo "  [note] $*"
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_interactive() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    die "project initialization requires an interactive terminal"
  fi
}

confirm_initialization() {
  local answer
  read -r -p "  Apply these changes? [Y/n] " answer
  if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
    die "project initialization cancelled"
  fi
}

initialize_project() {
  local template_module="github.com/prefeitura-rio/go-library-template"
  local package_name
  local module_path

  if ! grep -q "$template_module" go.mod; then
    return
  fi

  require_interactive

  [[ -f go.mod && -f devenv.nix && -f mylibrary.go && -f mylibrary_test.go ]] || die "template library files are missing"

  read -r -p "Package name: " package_name
  [[ "$package_name" =~ ^[a-z][a-z0-9_]*$ ]] || die "package name must be a valid lowercase Go identifier"
  case "$package_name" in
    break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var)
      die "package name cannot be a Go keyword"
      ;;
  esac
  [[ "$package_name" != "mylibrary" ]] || die "package name cannot be the template placeholder"
  [[ ! -e "$package_name.go" && ! -e "${package_name}_test.go" ]] || die "target package files already exist"

  read -r -p "Go module path: " module_path
  [[ "$module_path" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*(/[A-Za-z0-9._~-]+)+$ ]] || die "Go module path is invalid"
  [[ "$module_path" != "$template_module" ]] || die "Go module path cannot be the template placeholder"

  echo ""
  echo "Initializing project from template..."
  echo ""
  echo "  Package name  : $package_name"
  echo "  Go module path: $module_path"
  echo ""
  echo "  Changes to apply:"
  echo "    rename  mylibrary.go       -> $package_name.go"
  echo "    rename  mylibrary_test.go  -> ${package_name}_test.go"
  echo "    update  package clauses and doc comment"
  echo "    update  go.mod and test import"
  echo "    update  devenv.nix           (name field)"

  confirm_initialization

  mv mylibrary.go "$package_name.go"
  mv mylibrary_test.go "${package_name}_test.go"
  sed -i "s|github.com/prefeitura-rio/go-library-template|$module_path|g" "${package_name}_test.go"
  sed -i "s|package mylibrary|package $package_name|g" "$package_name.go"
  sed -i "s|Package mylibrary|Package $package_name|g" "$package_name.go"
  sed -i "s|package mylibrary_test|package ${package_name}_test|g" "${package_name}_test.go"
  sed -i "s|mylibrary\.|$package_name.|g" "${package_name}_test.go"
  sed -i "s|go-library-template|$package_name|g" devenv.nix
  sed -i "s|^module $template_module$|module $module_path|" go.mod
  ok "Project initialized"
}

initialize_project

step "Checking for Nix..."

if command -v nix &>/dev/null; then
  ok "Nix is already installed: $(nix --version)"
else
  step "Installing Nix + devenv via the official devenv installer..."
  note "This will install Nix system-wide and may ask for your password."
  note "Source: https://devenv.sh/getting-started/"
  curl -L https://devenv.sh/install.sh | bash

  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi

  ok "Nix installed: $(nix --version)"
fi

step "Checking for devenv..."

if command -v devenv &>/dev/null; then
  ok "devenv is already installed: $(devenv version)"
else
  step "Installing devenv via nix profile..."
  mkdir -p "$HOME/.config/nix"
  if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    ok "Enabled nix-command and flakes in ~/.config/nix/nix.conf"
  fi

  nix profile install nixpkgs#devenv
  ok "devenv installed: $(devenv version)"
fi

step "Setting up devenv shell hook for auto-activation..."

SHELL_NAME="$(basename "${SHELL:-bash}")"

case "$SHELL_NAME" in
  bash)
    HOOK_SNIPPET='eval "$(devenv hook bash)"'
    HOOK_FILE="$HOME/.bashrc"
    ;;
  zsh)
    HOOK_SNIPPET='eval "$(devenv hook zsh)"'
    HOOK_FILE="$HOME/.zshrc"
    ;;
  fish | nu)
    ok "devenv hook is loaded automatically for $SHELL_NAME — nothing to do."
    HOOK_SNIPPET=""
    HOOK_FILE=""
    ;;
  *)
    HOOK_SNIPPET=""
    HOOK_FILE=""
    ;;
esac

if [ -n "$HOOK_FILE" ]; then
  if grep -q 'devenv hook' "$HOOK_FILE" 2>/dev/null; then
    ok "devenv hook already present in $HOOK_FILE"
  else
    echo "$HOOK_SNIPPET" >> "$HOOK_FILE"
    ok "Added devenv hook to $HOOK_FILE"
  fi
elif [ -z "$HOOK_SNIPPET" ] && [ "$SHELL_NAME" != "fish" ] && [ "$SHELL_NAME" != "nu" ]; then
  note "Unknown shell '$SHELL_NAME'."
  note "Add the devenv hook manually: https://devenv.sh/auto-activation/"
fi

step "Trusting devenv project..."
devenv allow
ok "devenv project trusted"

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo "============================================================"
echo ""
echo " Open a new terminal. The environment activates automatically"
echo " when you navigate to this directory."
echo ""
