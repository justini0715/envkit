#!/usr/bin/env bash
set -euo pipefail

TASK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$TASK_DIR/.." && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

USER_REQUEST_FILE=${USER_REQUEST_FILE:-"$ROOT_DIR/config/user/request.txt"}
PLUGINS_FILE=${PLUGINS_FILE:-"$ROOT_DIR/config/zsh/plugins.txt"}
THEME_FILE=${THEME_FILE:-"$ROOT_DIR/config/zsh/theme.txt"}
USER_CONF_TARGET=${USER_CONF_TARGET:-"$HOME/.config/zsh/conf.d/30-dev-env-user.zsh"}

declare -a _tmp_files=()
cleanup() {
  if [ "${#_tmp_files[@]}" -gt 0 ]; then
    rm -f "${_tmp_files[@]}"
  fi
}
trap cleanup EXIT

read_request_text() {
  if [ "${USER_REQUEST_TEXT+x}" = "x" ]; then
    printf '%s' "${USER_REQUEST_TEXT}"
    return 0
  fi

  if [ ! -e "$USER_REQUEST_FILE" ]; then
    printf ''
    return 0
  fi

  [ -r "$USER_REQUEST_FILE" ] || die "request file is not readable: $USER_REQUEST_FILE"
  cat "$USER_REQUEST_FILE"
}

normalize_alias_specs() {
  local spec chunk normalized
  declare -a result=()

  for spec in "$@"; do
    IFS=',' read -r -a chunks <<< "$spec"
    for chunk in "${chunks[@]}"; do
      normalized="$(trim_whitespace "$chunk")"
      [ -z "$normalized" ] && continue

      if [[ "$normalized" == alias[[:space:]]* ]]; then
        result+=("$normalized")
      elif [[ "$normalized" == *=* ]]; then
        result+=("alias $normalized")
      else
        die "invalid aliases entry: '$normalized'"
      fi
    done
  done

  if [ "${#result[@]}" -gt 0 ]; then
    printf '%s
' "${result[@]}"
  fi
}

normalize_plugins() {
  local raw_plugins=${1:?raw_plugins is required}
  local plugin normalized seen=' '
  declare -a plugins=()

  normalized="$(printf '%s' "$raw_plugins" | tr ',	' '  ' | xargs)"
  [ -n "$normalized" ] || die 'plugins directive is empty'

  for plugin in $normalized; do
    [[ "$plugin" =~ ^[A-Za-z0-9._+-]+$ ]] || die "invalid plugin name: '$plugin'"
    case " $seen " in
      *" $plugin "*) continue ;;
    esac
    seen="${seen}${plugin} "
    plugins+=("$plugin")
  done

  printf '%s
' "${plugins[@]}"
}

normalize_theme() {
  local normalized
  normalized="$(trim_whitespace "${1:-}")"
  [ -n "$normalized" ] || die 'theme directive is empty'
  is_valid_theme_name "$normalized" || die "invalid theme name: '$normalized'"
  printf '%s' "$normalized"
}

request_text="$(read_request_text)"
if [ -z "$(trim_whitespace "$request_text")" ]; then
  echo 'apply_user_request: no input request. no-op.'
  exit 0
fi

request_text="${request_text//$''/}"
request_text="${request_text//;/$'
'}"

plugins_raw=''
theme_raw=''
declare -a aliases_raw=()
declare -a init_commands=()

line_no=0
while IFS= read -r line || [ -n "$line" ]; do
  line_no=$((line_no + 1))
  line="$(trim_whitespace "$line")"
  [ -z "$line" ] && continue
  [[ "$line" == \#* ]] && continue

  [[ "$line" == *:* ]] || die "unsupported syntax at line $line_no: '$line'"
  key="$(trim_whitespace "${line%%:*}")"
  value="$(trim_whitespace "${line#*:}")"
  key="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
  [ -n "$value" ] || die "empty value for '$key' at line $line_no"

  case "$key" in
    plugins)
      plugins_raw="${plugins_raw:+$plugins_raw }$value"
      ;;
    theme)
      theme_raw="$value"
      ;;
    aliases)
      aliases_raw+=("$value")
      ;;
    init)
      init_commands+=("$value")
      ;;
    *)
      die "unsupported directive '$key' at line $line_no"
      ;;
  esac
done <<< "$request_text"

if [ -n "$plugins_raw" ]; then
  mapfile -t plugins_out < <(normalize_plugins "$plugins_raw")
  tmp_plugins="$(mktemp)"
  _tmp_files+=("$tmp_plugins")
  printf '%s
' "${plugins_out[@]}" > "$tmp_plugins"
  sync_file_with_backup "$tmp_plugins" "$PLUGINS_FILE"
  echo "apply_user_request: updated plugins file -> $PLUGINS_FILE"
fi

if [ -n "$theme_raw" ]; then
  theme_out="$(normalize_theme "$theme_raw")"
  tmp_theme="$(mktemp)"
  _tmp_files+=("$tmp_theme")
  {
    echo '# Managed by dev-env apply-user task'
    echo '# First non-comment line is used by configure.'
    printf '%s
' "$theme_out"
  } > "$tmp_theme"
  sync_file_with_backup "$tmp_theme" "$THEME_FILE"
  echo "apply_user_request: updated theme file -> $THEME_FILE"
fi

if [ "${#aliases_raw[@]}" -gt 0 ] || [ "${#init_commands[@]}" -gt 0 ]; then
  tmp_conf="$(mktemp)"
  _tmp_files+=("$tmp_conf")
  {
    echo '# Managed by dev-env apply-user task'
    echo '# Source: USER_REQUEST_TEXT or USER_REQUEST_FILE'

    if [ "${#aliases_raw[@]}" -gt 0 ]; then
      mapfile -t aliases_out < <(normalize_alias_specs "${aliases_raw[@]}")
      echo
      echo '# aliases'
      printf '%s
' "${aliases_out[@]}"
    fi

    if [ "${#init_commands[@]}" -gt 0 ]; then
      echo
      echo '# init (interactive shell only)'
      echo 'if [[ -o interactive ]]; then'
      for init_command in "${init_commands[@]}"; do
        printf '  %s
' "$init_command"
      done
      echo 'fi'
    fi
  } > "$tmp_conf"
  sync_file_with_backup "$tmp_conf" "$USER_CONF_TARGET"
  echo "apply_user_request: updated drop-in file -> $USER_CONF_TARGET"
fi
