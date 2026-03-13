#!/usr/bin/env bash
set -euo pipefail

ZSH_DIR=${ZSH_DIR:-"$HOME/.oh-my-zsh"}
OHMYZSH_INSTALL_URL=${OHMYZSH_INSTALL_URL:-"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"}
OHMYZSH_INSTALL_SHA256=${OHMYZSH_INSTALL_SHA256:-""}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

if [ -f "$ZSH_DIR/oh-my-zsh.sh" ]; then
  echo "Oh My Zsh already installed at $ZSH_DIR"
  exit 0
fi

if is_dry_run; then
  echo "[dry-run] Would install Oh My Zsh into $ZSH_DIR from $OHMYZSH_INSTALL_URL"
  exit 0
fi

if ! command -v curl > /dev/null 2>&1; then
  die "curl not found. Run 'envkit packages' first."
fi

tmp_installer="$(mktemp)"
trap 'rm -f "$tmp_installer"' EXIT

curl -fsSL "$OHMYZSH_INSTALL_URL" -o "$tmp_installer"

if [ -n "$OHMYZSH_INSTALL_SHA256" ]; then
  printf '%s  %s
' "$OHMYZSH_INSTALL_SHA256" "$tmp_installer" | sha256sum -c -
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes ZSH="$ZSH_DIR" sh "$tmp_installer"
