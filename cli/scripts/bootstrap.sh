#!/usr/bin/env bash
# scripts/bootstrap.sh — One-time setup: installs Nix, devenv, and the devenv
# shell hook for automatic environment activation.
# Usage: bash scripts/bootstrap.sh
# After: open a new terminal, navigate to the repo, and run `devenv allow`.

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

step "Setting up devenv shell hook for auto-activation..."

# Fish and Nushell load the devenv hook automatically when devenv is installed
# via Nix; no manual setup needed. Bash and Zsh require one line in the RC file.
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

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo "============================================================"
echo ""
echo " Next steps:"
echo ""
echo "   1. Open a new terminal (so the shell hook takes effect)"
echo "   2. Navigate to this repository"
echo "   3. Run: devenv allow"
echo ""
echo " After step 3, the environment activates automatically"
echo " every time you cd into this directory."
echo ""
