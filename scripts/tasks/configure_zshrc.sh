#!/usr/bin/env bash
set -euo pipefail

ZSHRC=${ZSHRC:-"$HOME/.zshrc"}
ZSH_DIR=${ZSH_DIR:-"$HOME/.oh-my-zsh"}
ZSH_CONF_DIR=${ZSH_CONF_DIR:-"$HOME/.config/zsh/conf.d"}
ZSH_CONF_FILE=${ZSH_CONF_FILE:-"10-dev-env-ohmyzsh.zsh"}
PLUGINS=${PLUGINS:-"git"}
PLUGINS_FILE=${PLUGINS_FILE:-""}
DEFAULT_THEME=${DEFAULT_THEME:-"robbyrussell"}
USER_CONF_TARGET=${USER_CONF_TARGET:-"$ZSH_CONF_DIR/30-dev-env-user.zsh"}
THEME_FILE=${THEME_FILE:-""}

TASK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$TASK_DIR/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

MANAGED_FILE="$ZSH_CONF_DIR/$ZSH_CONF_FILE"
START_MARKER="# >>> dev-env zsh bootstrap >>>"
END_MARKER="# <<< dev-env zsh bootstrap <<<"

resolved_plugins="$(load_plugins "$PLUGINS" "$PLUGINS_FILE")"
resolved_theme="$(resolve_theme "$DEFAULT_THEME" "$THEME_FILE")"
plugins_line="plugins=($resolved_plugins)"
theme_line="ZSH_THEME=\"$resolved_theme\""

managed_tmp="$(mktemp)"
existing_tmp="$(mktemp)"
output_tmp="$(mktemp)"
trap 'rm -f "$managed_tmp" "$existing_tmp" "$output_tmp"' EXIT

cat > "$managed_tmp" << EOF_MANAGED
# Managed by dev-env. Re-run 'dev-env configure' to update.
# Profile: ${DEV_ENV_PROFILE:-minimal}
$theme_line
$plugins_line
EOF_MANAGED

if [ -f "$ZSHRC" ]; then
  if grep -Fq "$START_MARKER" "$ZSHRC" && grep -Fq "$END_MARKER" "$ZSHRC"; then
    awk -v start="$START_MARKER" -v end="$END_MARKER" '
      $0 == start { in_block = 1; next }
      $0 == end { in_block = 0; next }
      !in_block { print }
    ' "$ZSHRC" > "$existing_tmp"
  else
    cat "$ZSHRC" > "$existing_tmp"
  fi
else
  : > "$existing_tmp"
fi

if grep -Eq '^[[:space:]]*# init-zsh[[:space:]]*$' "$existing_tmp"; then
  awk '
    BEGIN { in_legacy_init = 0 }
    {
      if (!in_legacy_init && $0 ~ /^[[:space:]]*# init-zsh[[:space:]]*$/) {
        in_legacy_init = 1
        next
      }

      if (in_legacy_init) {
        if ($0 ~ /^[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*clear[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*ls[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*python3[[:space:]]+~\/\.bg\.py[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*python3[[:space:]]+\$HOME\/\.bg\.py[[:space:]]*$/) { next }
        in_legacy_init = 0
      }

      print
    }
  ' "$existing_tmp" > "$output_tmp"
  mv "$output_tmp" "$existing_tmp"
fi

has_omz_source=0
if grep -Eq 'oh-my-zsh\.sh' "$existing_tmp"; then
  has_omz_source=1
fi

awk \
  -v start="$START_MARKER" \
  -v end="$END_MARKER" \
  -v conf_dir="$ZSH_CONF_DIR" \
  -v zsh_dir="$ZSH_DIR" \
  -v has_omz_source="$has_omz_source" '
  BEGIN {
    block[1] = start
    block[2] = "if [ -d \"" conf_dir "\" ]; then"
    block[3] = "  for _dev_env_conf in \"" conf_dir "\"/*.zsh(N); do"
    block[4] = "    [ -r \"$_dev_env_conf\" ] && source \"$_dev_env_conf\""
    block[5] = "  done"
    block[6] = "  unset _dev_env_conf"
    block[7] = "fi"
    block_len = 7

    if (has_omz_source == 0) {
      block[++block_len] = "if [ -z \"${ZSH:-}\" ]; then"
      block[++block_len] = "  export ZSH=\"" zsh_dir "\""
      block[++block_len] = "fi"
      block[++block_len] = "if [ -f \"$ZSH/oh-my-zsh.sh\" ]; then"
      block[++block_len] = "  source \"$ZSH/oh-my-zsh.sh\""
      block[++block_len] = "fi"
    }

    block[++block_len] = end
  }
  {
    if (!inserted && $0 ~ /oh-my-zsh\.sh/) {
      for (i = 1; i <= block_len; i++) {
        print block[i]
      }
      inserted = 1
    }
    print
  }
  END {
    if (!inserted) {
      if (NR > 0) {
        print ""
      }
      for (i = 1; i <= block_len; i++) {
        print block[i]
      }
    }
  }
' "$existing_tmp" > "$output_tmp"

sync_file_with_backup "$managed_tmp" "$MANAGED_FILE"
sync_file_with_backup "$output_tmp" "$ZSHRC"

if [ -n "${USER_REQUEST_TEXT+x}" ] || [ -f "${USER_REQUEST_FILE:-}" ]; then
  DEV_ENV_DRY_RUN="${DEV_ENV_DRY_RUN:-0}" \
    DEV_ENV_PROFILE="${DEV_ENV_PROFILE:-minimal}" \
    USER_CONF_TARGET="$USER_CONF_TARGET" \
    PLUGINS_FILE="$PLUGINS_FILE" \
    THEME_FILE="$THEME_FILE" \
    USER_REQUEST_FILE="${USER_REQUEST_FILE:-}" \
    "$TASK_DIR/apply_user_request.sh"
fi

echo "Configured $ZSHRC and $MANAGED_FILE"
echo "Resolved plugins: $resolved_plugins"
echo "Resolved theme: $resolved_theme"
