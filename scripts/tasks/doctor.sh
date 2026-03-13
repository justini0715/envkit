#!/usr/bin/env bash
set -euo pipefail

ZSHRC=${ZSHRC:-"$HOME/.zshrc"}
ZSH_DIR=${ZSH_DIR:-"$HOME/.oh-my-zsh"}
ZSH_CONF_DIR=${ZSH_CONF_DIR:-"$HOME/.config/zsh/conf.d"}
PLUGINS_FILE=${PLUGINS_FILE:-""}
THEME_FILE=${THEME_FILE:-""}
USER_REQUEST_FILE=${USER_REQUEST_FILE:-""}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

has_error=0
profile_name="$(resolve_profile "${ENVKIT_PROFILE:-minimal}")"
resolved_theme="$(resolve_theme 'robbyrussell' "$THEME_FILE")"
resolved_plugins="$(load_plugins 'git' "$PLUGINS_FILE")"

ok() {
  echo "OK: $*"
}

warn_doctor() {
  echo "WARN: $*"
}

fail() {
  echo "FAIL: $*"
  has_error=1
}

check_command() {
  local cmd=${1:?cmd is required}
  if command -v "$cmd" > /dev/null 2>&1; then
    ok "command available: $cmd"
  else
    fail "command missing: $cmd"
  fi
}

echo "[doctor] phase + profile"
echo "Phase: $(current_phase_name)"
echo "Profile: $profile_name"
echo "Resolved theme: $resolved_theme"
echo "Resolved plugins: $resolved_plugins"

echo
echo '[doctor] planning artifacts'
if [ -f "$(current_phase_prd_path)" ]; then
  ok 'phase PRD present'
else
  fail 'phase PRD missing'
fi

if [ -f "$(current_phase_test_spec_path)" ]; then
  ok 'phase test spec present'
else
  fail 'phase test spec missing'
fi

echo
echo '[doctor] basic commands'
for cmd in git curl zsh gcc awk sed grep; do
  check_command "$cmd"
done

echo
echo '[doctor] core files'
if [ -r "$ZSHRC" ]; then
  ok "readable zshrc: $ZSHRC"
else
  warn_doctor "zshrc not readable yet: $ZSHRC"
fi

if [ -d "$ZSH_CONF_DIR" ]; then
  ok "zsh drop-in dir exists: $ZSH_CONF_DIR"
else
  warn_doctor "zsh drop-in dir missing: $ZSH_CONF_DIR"
fi

if [ -d "$ZSH_DIR" ]; then
  ok "oh-my-zsh dir exists: $ZSH_DIR"
else
  warn_doctor "oh-my-zsh dir missing: $ZSH_DIR"
fi

if [ -n "$USER_REQUEST_FILE" ]; then
  if [ -r "$USER_REQUEST_FILE" ]; then
    ok "user request file readable: $USER_REQUEST_FILE"
  else
    warn_doctor "user request file missing/unreadable: $USER_REQUEST_FILE"
  fi
fi

echo
echo '[doctor] startup safety checks'
if [ -f "$ZSHRC" ] && grep -Eq '^[[:space:]]*# init-zsh[[:space:]]*$|python3[[:space:]]+~/.bg.py|python3[[:space:]]+[$]HOME/.bg.py|^[[:space:]]*ls[[:space:]]*$' "$ZSHRC"; then
  fail "legacy startup defaults still exist in $ZSHRC"
else
  ok "no legacy startup defaults detected in $ZSHRC"
fi

if [ -n "$THEME_FILE" ] && [ -r "$THEME_FILE" ]; then
  theme_value="$(trim_whitespace "$(read_first_data_line "$THEME_FILE")")"
  if [ -z "$theme_value" ]; then
    warn_doctor "theme file has no explicit value; profile/default will be used"
  elif is_valid_theme_name "$theme_value"; then
    ok "theme file value is valid: $theme_value"
  else
    fail "invalid theme value in $THEME_FILE: $theme_value"
  fi
fi

echo
echo '[doctor] verify task'
if ! ENVKIT_PROFILE="$profile_name" "$TASKS_DIR/verify.sh"; then
  has_error=1
fi

echo
if [ "$has_error" -ne 0 ]; then
  echo '[doctor] completed with failures.'
  exit 1
fi

echo '[doctor] all checks passed.'
