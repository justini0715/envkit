#!/usr/bin/env bash
set -euo pipefail

ZSHRC=${ZSHRC:-"$HOME/.zshrc"}
ZSH_DIR=${ZSH_DIR:-"$HOME/.oh-my-zsh"}
ZSH_CUSTOM=${ZSH_CUSTOM:-"$ZSH_DIR/custom"}
ZSH_CONF_DIR=${ZSH_CONF_DIR:-"$HOME/.config/zsh/conf.d"}
PLUGINS=${PLUGINS:-"git"}
PLUGINS_FILE=${PLUGINS_FILE:-""}
THEME_FILE=${THEME_FILE:-""}
DEFAULT_THEME=${DEFAULT_THEME:-"robbyrussell"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

profile_name="$(resolve_profile "${DEV_ENV_PROFILE:-minimal}")"
plugins_resolved="$(load_plugins "$PLUGINS" "$PLUGINS_FILE")"
theme_resolved="$(resolve_theme "$DEFAULT_THEME" "$THEME_FILE")"
has_error=0

printf 'profile: %s
' "$profile_name"
printf 'theme:   %s
' "$theme_resolved"
printf 'git:     %s
' "$(git --version 2> /dev/null || echo 'not installed')"
printf 'curl:    %s
' "$(curl --version 2> /dev/null | head -n 1 || echo 'not installed')"
printf 'zsh:     %s
' "$(zsh --version 2> /dev/null || echo 'not installed')"
printf 'gcc:     %s
' "$(gcc --version 2> /dev/null | head -n 1 || echo 'not installed')"

for cmd in git curl zsh gcc; do
  command -v "$cmd" > /dev/null 2>&1 || has_error=1
done

[ -f "$ZSH_DIR/oh-my-zsh.sh" ] || has_error=1
[ -f "$ZSHRC" ] || has_error=1
[ -f "$ZSH_CONF_DIR/10-dev-env-ohmyzsh.zsh" ] || has_error=1

if [ -f "$ZSH_DIR/oh-my-zsh.sh" ]; then
  echo 'oh-my-zsh: installed'
else
  echo 'oh-my-zsh: missing'
fi

echo 'plugins:'
for plugin in $plugins_resolved; do
  if [ -d "$ZSH_DIR/plugins/$plugin" ]; then
    echo "  - $plugin (builtin): ok"
  elif [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "  - $plugin (custom): ok"
  else
    echo "  - $plugin: missing"
    has_error=1
  fi
done

if grep -Eq '^[[:space:]]*clear[[:space:]]*$|python3[[:space:]]+~/.bg.py|python3[[:space:]]+[$]HOME/.bg.py|^[[:space:]]*ls[[:space:]]*$' "$ZSHRC"; then
  echo 'startup safety: failed (unsafe legacy defaults still present)' >&2
  has_error=1
else
  echo 'startup safety: ok'
fi

if [ "$has_error" -ne 0 ]; then
  echo 'verify: failed' >&2
  exit 1
fi

echo 'verify: ok'
