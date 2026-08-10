#!/usr/bin/env bash
# scripts/bootstrap.sh — One-time setup: installs Nix, devenv, and direnv.
# Usage: bash scripts/bootstrap.sh
# After: run `direnv allow` once per repo.

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

step "Checking for Nix..."

if command -v nix &>/dev/null; then
  ok "Nix is already installed: $(nix --version)"
else
  step "Installing Nix + devenv via the official devenv installer..."
  note "This will install Nix system-wide and may ask for your password."
  note "Source: https://devenv.sh/getting-started/"
  curl -L https://devenv.sh/install.sh | bash

  # Source nix-daemon's env now so `nix` works in this script; the installer
  # only updates login shells.
  # shellcheck disable=SC1091
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
  # Enable the experimental features nix profile requires.
  mkdir -p "$HOME/.config/nix"
  if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    ok "Enabled nix-command and flakes in ~/.config/nix/nix.conf"
  fi

  nix profile install nixpkgs#devenv
  ok "devenv installed: $(devenv version)"
fi

step "Checking for direnv..."

if command -v direnv &>/dev/null; then
  ok "direnv is already installed: $(direnv version)"
else
  step "Installing direnv via nix profile..."
  nix profile install nixpkgs#direnv
  ok "direnv installed: $(direnv version)"
fi

step "Shell hook setup..."

SHELL_NAME="$(basename "${SHELL:-bash}")"

HOOK_ALREADY_SET=false
case "$SHELL_NAME" in
  bash)
    if grep -q 'direnv hook bash' "$HOME/.bashrc" 2>/dev/null; then
      HOOK_ALREADY_SET=true
    fi
    HOOK_SNIPPET='eval "$(direnv hook bash)"'
    HOOK_FILE="$HOME/.bashrc"
    ;;
  zsh)
    if grep -q 'direnv hook zsh' "$HOME/.zshrc" 2>/dev/null; then
      HOOK_ALREADY_SET=true
    fi
    HOOK_SNIPPET='eval "$(direnv hook zsh)"'
    HOOK_FILE="$HOME/.zshrc"
    ;;
  fish)
    if grep -q 'direnv hook fish' "$HOME/.config/fish/config.fish" 2>/dev/null; then
      HOOK_ALREADY_SET=true
    fi
    HOOK_SNIPPET='direnv hook fish | source'
    HOOK_FILE="$HOME/.config/fish/config.fish"
    ;;
  *)
    HOOK_SNIPPET="# see https://direnv.net/docs/hook.html for your shell"
    HOOK_FILE="your shell's startup file"
    ;;
esac

if [ "$HOOK_ALREADY_SET" = true ]; then
  ok "direnv hook already present in $HOOK_FILE"
else
  echo ""
  echo "  ACTION REQUIRED: Add the direnv hook to your shell."
  echo ""
  echo "  Run this command:"
  echo ""
  echo "    echo '$HOOK_SNIPPET' >> $HOOK_FILE"
  echo ""
  echo "  Then restart your terminal (or run: source $HOOK_FILE)"
  echo ""
  echo "  This is a one-time setup. direnv will then automatically"
  echo "  activate environments in any repo that has an .envrc."
fi

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo "============================================================"
echo ""
echo " Next steps:"
echo ""
echo "   1. Open a new terminal (so the Nix and direnv changes take effect)"
echo "   2. Navigate to this repository"
echo "   3. Run: direnv allow"
echo ""
echo " After step 3, the development environment activates automatically"
echo " every time you enter this directory."
echo ""
