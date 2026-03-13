#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

zsh_path="$(command -v zsh || true)"
[ -n "$zsh_path" ] || {
  if is_dry_run; then
    zsh_path='/usr/bin/zsh'
  else
    die 'zsh not found; install it first.'
  fi
}

current_shell="${SHELL:-}"
if [ "$current_shell" = "$zsh_path" ]; then
  echo "Default shell already set to $zsh_path"
  exit 0
fi

run_cmd chsh -s "$zsh_path"
