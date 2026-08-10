#!/usr/bin/env bash
# scripts/bootstrap.sh — One-time setup for a new developer machine.
#
# What this script does, in order:
#   1. Installs Nix (the package manager that everything else is built on)
#   2. Installs devenv  (the dev-environment tool that reads devenv.nix)
#   3. Installs direnv  (the shell extension that activates devenv automatically)
#   4. Prints shell-hook instructions so direnv works in every new terminal
#
# After running this script, you only need to run once per repo:
#   direnv allow
#
# From that point on, entering this directory in any terminal activates the
# full development environment automatically — Go, all tools, and git hooks.
#
# Usage:
#   bash scripts/bootstrap.sh

set -eu -o pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

# Print a section header so the output is easy to scan.
step() {
  echo ""
  echo "===> $*"
}

# Print a success checkmark.
ok() {
  echo "  [ok] $*"
}

# Print an informational note.
note() {
  echo "  [note] $*"
}

# ── Step 1: Nix ───────────────────────────────────────────────────────────────
#
# Nix is a package manager that guarantees reproducible builds.
# devenv is built on top of Nix — it uses Nix to create isolated,
# deterministic development environments.
#
# We detect whether Nix is already present before installing.
# The devenv installer (https://devenv.sh/getting-started/) bundles
# the official Nix installer and is the recommended way to get both
# Nix and devenv in a single step.

step "Checking for Nix..."

if command -v nix &>/dev/null; then
  ok "Nix is already installed: $(nix --version)"
else
  step "Installing Nix + devenv via the official devenv installer..."
  note "This will install Nix system-wide and may ask for your password."
  note "Source: https://devenv.sh/getting-started/"
  curl -L https://devenv.sh/install.sh | bash

  # The installer modifies /etc/profile and similar files, but those are only
  # sourced in a new login shell. We source nix-daemon's env file here so that
  # the `nix` command is immediately available in this running script.
  # shellcheck disable=SC1091
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi

  ok "Nix installed: $(nix --version)"
fi

# ── Step 2: devenv ────────────────────────────────────────────────────────────
#
# devenv reads devenv.nix and creates a shell with all declared tools (Go,
# golangci-lint, gofumpt, etc.) and registers git hooks automatically.
#
# If the devenv installer above already installed devenv, this step is a no-op.

step "Checking for devenv..."

if command -v devenv &>/dev/null; then
  ok "devenv is already installed: $(devenv version)"
else
  step "Installing devenv via nix profile..."
  # Enable Nix experimental features required by devenv (nix-command and flakes).
  # These are not enabled by default in Nix but are needed for `nix profile install`.
  mkdir -p "$HOME/.config/nix"
  if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    ok "Enabled nix-command and flakes in ~/.config/nix/nix.conf"
  fi

  nix profile install nixpkgs#devenv
  ok "devenv installed: $(devenv version)"
fi

# ── Step 3: direnv ────────────────────────────────────────────────────────────
#
# direnv is a shell extension that watches .envrc files.
# When you enter a directory that contains an .envrc, direnv automatically
# runs it and loads the environment.
#
# For this repo, .envrc contains `use devenv`, which means direnv will
# automatically activate the devenv environment whenever you enter this
# directory — without you needing to type `devenv shell` each time.

step "Checking for direnv..."

if command -v direnv &>/dev/null; then
  ok "direnv is already installed: $(direnv version)"
else
  step "Installing direnv via nix profile..."
  nix profile install nixpkgs#direnv
  ok "direnv installed: $(direnv version)"
fi

# ── Step 4: Shell hook instructions ──────────────────────────────────────────
#
# direnv works by hooking into your shell's prompt command.
# Without this hook, direnv is installed but inactive — it can't watch
# directories or load .envrc files automatically.
#
# The hook must be added to your shell's startup file and takes effect in
# every new terminal you open after that.
#
# We detect the current shell and print the exact command needed.

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

# ── Done ─────────────────────────────────────────────────────────────────────

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
