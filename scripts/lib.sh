#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." > /dev/null 2>&1
  pwd
}

current_phase_name() {
  printf '%s
' 'Phase 4 — Hardening and Polish'
}

current_phase_prd_path() {
  printf '%s/.omx/plans/prd-phase4-hardening.md
' "$(repo_root)"
}

current_phase_test_spec_path() {
  printf '%s/.omx/plans/test-spec-phase4-hardening.md
' "$(repo_root)"
}

warn() {
  echo "WARN: $*" >&2
}

info() {
  echo "INFO: $*"
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

is_dry_run() {
  [[ "${DEV_ENV_DRY_RUN:-0}" == "1" ]]
}

run_cmd() {
  if is_dry_run; then
    printf '[dry-run]'
    local arg=""
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '
'
    return 0
  fi

  "$@"
}

trim_whitespace() {
  local value=${1-}
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

read_first_data_line() {
  local source_file=${1:-}
  [ -n "$source_file" ] || return 0
  [ -r "$source_file" ] || return 0

  awk '
    {
      gsub(/$/, "", $0)
      if ($0 ~ /^[[:space:]]*#/ || $0 ~ /^[[:space:]]*$/) {
        next
      }
      print
      exit
    }
  ' "$source_file"
}

is_valid_theme_name() {
  local theme_name=${1-}
  [[ "$theme_name" =~ ^[A-Za-z0-9._/+:-]+$ ]]
}

generate_backup_suffix() {
  local ts
  ts="$(date +%Y%m%d%H%M%S%N 2> /dev/null || true)"
  if [ -z "$ts" ] || [ "$ts" = "N" ]; then
    ts="$(date +%Y%m%d%H%M%S)-$RANDOM"
  fi
  printf '%s-%s' "$ts" "$$"
}

sync_file_with_backup() {
  local source_file=${1:?source_file is required}
  local target_file=${2:?target_file is required}
  local backup_file=""
  local target_dir

  target_dir="$(dirname "$target_file")"

  if [ ! -r "$source_file" ]; then
    warn "source file not readable: $source_file"
    return 1
  fi

  if [ ! -d "$target_dir" ]; then
    if is_dry_run; then
      echo "[dry-run] mkdir -p $target_dir"
    else
      mkdir -p "$target_dir"
    fi
  fi

  if [ -f "$target_file" ] && cmp -s "$source_file" "$target_file"; then
    return 0
  fi

  if [ -e "$target_file" ]; then
    backup_file="${target_file}.dev-env.bak.$(generate_backup_suffix)"
    if is_dry_run; then
      echo "[dry-run] cp $target_file $backup_file"
    else
      cp "$target_file" "$backup_file"
      warn "backed up existing file: $backup_file"
    fi
  fi

  if is_dry_run; then
    echo "[dry-run] cp $source_file $target_file"
    return 0
  fi

  cp "$source_file" "$target_file"
}

profile_file() {
  local profile_name=${1:?profile name is required}
  printf '%s/config/profiles/%s.env
' "$(repo_root)" "$profile_name"
}

resolve_profile() {
  local requested_profile=${1:-${DEV_ENV_PROFILE:-minimal}}
  local file
  file="$(profile_file "$requested_profile")"
  [ -r "$file" ] || die "profile not found or unreadable: $requested_profile ($file)"
  printf '%s
' "$requested_profile"
}

profile_field() {
  local requested_profile=${1:-}
  local field_name=${2:?field name is required}
  local resolved_profile file
  resolved_profile="$(resolve_profile "$requested_profile")"
  file="$(profile_file "$resolved_profile")"

  (
    PROFILE_NAME=''
    PROFILE_DESCRIPTION=''
    PROFILE_PLUGINS=''
    PROFILE_THEME=''
    PROFILE_REQUEST_FILE=''
    # shellcheck disable=SC1090
    . "$file"
    case "$field_name" in
      PROFILE_NAME)
        printf '%s
' "${PROFILE_NAME:-$resolved_profile}"
        ;;
      PROFILE_DESCRIPTION)
        printf '%s
' "${PROFILE_DESCRIPTION:-}"
        ;;
      PROFILE_PLUGINS)
        printf '%s
' "${PROFILE_PLUGINS:-}"
        ;;
      PROFILE_THEME)
        printf '%s
' "${PROFILE_THEME:-}"
        ;;
      PROFILE_REQUEST_FILE)
        printf '%s
' "${PROFILE_REQUEST_FILE:-}"
        ;;
      *)
        exit 1
        ;;
    esac
  )
}

profile_plugins() {
  profile_field "$1" PROFILE_PLUGINS
}

profile_theme() {
  profile_field "$1" PROFILE_THEME
}

profile_request_file() {
  profile_field "$1" PROFILE_REQUEST_FILE
}

resolve_request_file() {
  local requested_profile=${1:-}
  local fallback_file=${2:-}
  local configured_file=''
  local root=''

  configured_file="$(trim_whitespace "$(profile_request_file "$requested_profile")")"
  if [ -z "$configured_file" ]; then
    printf '%s
' "$fallback_file"
    return 0
  fi

  root="$(repo_root)"
  case "$configured_file" in
    /*)
      printf '%s
' "$configured_file"
      ;;
    *)
      printf '%s/%s
' "$root" "$configured_file"
      ;;
  esac
}

load_plugins() {
  local default_plugins=${1:-git}
  local plugins_file=${2:-}
  local plugin_list=''
  local profile_name

  if [ -n "$plugins_file" ] && [ -r "$plugins_file" ]; then
    plugin_list="$(grep -Ev '^[[:space:]]*#|^[[:space:]]*$' "$plugins_file" | tr '
' ' ' | xargs || true)"
  fi

  if [ -z "$plugin_list" ]; then
    profile_name="$(resolve_profile "${DEV_ENV_PROFILE:-minimal}")"
    plugin_list="$(profile_plugins "$profile_name" | xargs || true)"
  fi

  if [ -n "$plugin_list" ]; then
    echo "$plugin_list"
  else
    echo "$default_plugins" | xargs
  fi
}

resolve_theme() {
  local default_theme=${1:-robbyrussell}
  local theme_file=${2:-}
  local resolved_theme=''
  local profile_name=''

  if [ -n "${THEME+x}" ] && [ -n "$(trim_whitespace "${THEME}")" ]; then
    resolved_theme="$(trim_whitespace "${THEME}")"
  fi

  if [ -z "$resolved_theme" ] && [ -n "$theme_file" ] && [ -r "$theme_file" ]; then
    resolved_theme="$(trim_whitespace "$(read_first_data_line "$theme_file")")"
  fi

  if [ -z "$resolved_theme" ]; then
    profile_name="$(resolve_profile "${DEV_ENV_PROFILE:-minimal}")"
    resolved_theme="$(trim_whitespace "$(profile_theme "$profile_name")")"
  fi

  if [ -z "$resolved_theme" ]; then
    resolved_theme="$default_theme"
  fi

  if ! is_valid_theme_name "$resolved_theme"; then
    warn "invalid theme '$resolved_theme'. Falling back to '$default_theme'."
    resolved_theme="$default_theme"
  fi

  printf '%s
' "$resolved_theme"
}

get_locked_ref() {
  local plugin=${1:?plugin is required}
  local lock_file=${2:-}
  if [ -n "$lock_file" ] && [ -r "$lock_file" ]; then
    awk -F= -v key="$plugin" '
      $1 !~ /^[[:space:]]*#/ && $1 == key {
        gsub(/^[ 	]+|[ 	]+$/, "", $2)
        print $2
        exit
      }
    ' "$lock_file"
  fi
}

plugin_repo_url() {
  local plugin=${1:?plugin is required}
  case "$plugin" in
    git)
      printf '%s
' ''
      ;;
    zsh-autosuggestions)
      printf '%s
' 'https://github.com/zsh-users/zsh-autosuggestions.git'
      ;;
    zsh-syntax-highlighting)
      printf '%s
' 'https://github.com/zsh-users/zsh-syntax-highlighting.git'
      ;;
    zsh-completions)
      printf '%s
' 'https://github.com/zsh-users/zsh-completions.git'
      ;;
    zsh-history-substring-search)
      printf '%s
' 'https://github.com/zsh-users/zsh-history-substring-search.git'
      ;;
    *)
      return 1
      ;;
  esac
}
