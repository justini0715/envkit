#!/usr/bin/env bash
set -euo pipefail

ZSH_DIR=${ZSH_DIR:-"$HOME/.oh-my-zsh"}
ZSH_CUSTOM=${ZSH_CUSTOM:-"$ZSH_DIR/custom"}
PLUGINS=${PLUGINS:-"git"}
PLUGINS_FILE=${PLUGINS_FILE:-""}
PLUGIN_LOCK_FILE=${PLUGIN_LOCK_FILE:-""}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

clone_or_pin_repo() {
  local repo=${1:?repo is required}
  local dir=${2:?dir is required}
  local ref=${3:-}

  run_cmd git clone --depth 1 "$repo" "$dir"
  if [ -n "$ref" ]; then
    run_cmd git -C "$dir" fetch --depth 1 origin "$ref"
    run_cmd git -C "$dir" checkout --detach FETCH_HEAD
  fi
}

PLUGINS="$(load_plugins "$PLUGINS" "$PLUGINS_FILE")"
if is_dry_run; then
  echo "[dry-run] mkdir -p $ZSH_CUSTOM/plugins"
else
  mkdir -p "$ZSH_CUSTOM/plugins"
fi
error_count=0

for plugin in $PLUGINS; do
  dir="$ZSH_CUSTOM/plugins/$plugin"
  ref="$(get_locked_ref "$plugin" "$PLUGIN_LOCK_FILE")"

  if [ -d "$dir/.git" ] || [ -d "$dir" ]; then
    echo "$plugin already installed"
    continue
  fi

  repo="$(plugin_repo_url "$plugin" 2> /dev/null || true)"
  case "$plugin" in
    git)
      echo "$plugin is a built-in Oh My Zsh plugin"
      ;;
    '') ;;
    *)
      if [ -z "$repo" ]; then
        echo "Unknown plugin '$plugin'." >&2
        error_count=$((error_count + 1))
        continue
      fi
      clone_or_pin_repo "$repo" "$dir" "$ref"
      ;;
  esac
done

if [ "$error_count" -gt 0 ]; then
  echo "Plugin installation failed: $error_count unknown plugin(s)." >&2
  exit 1
fi
