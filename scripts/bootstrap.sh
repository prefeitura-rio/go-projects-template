#!/usr/bin/env bash
# scripts/bootstrap.sh — One-time setup: installs Nix and devenv.
# Usage: bash scripts/bootstrap.sh
# After: open a new terminal and run `devenv shell` to enter the environment.

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

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo "============================================================"
echo ""
echo " Next steps:"
echo ""
echo "   1. Open a new terminal (so the Nix changes take effect)"
echo "   2. Navigate to this repository"
echo "   3. Run: devenv shell"
echo ""
echo " The development environment (Go, tools, git hooks) activates"
echo " inside the devenv shell."
echo ""
