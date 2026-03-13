#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
DEFAULT_PROFILE='minimal'
DEFAULT_PLUGINS_FILE="$ROOT_DIR/config/zsh/plugins.txt"
DEFAULT_PLUGIN_LOCK_FILE="$ROOT_DIR/config/zsh/plugin-lock.txt"
DEFAULT_THEME_FILE="$ROOT_DIR/config/zsh/theme.txt"
DEFAULT_REQUEST_FILE="$ROOT_DIR/config/user/request.txt"

usage() {
  cat << 'EOF_USAGE'
Usage: dev-env <command> [options]

Commands:
  bootstrap [--profile <name>] [--dry-run] [--set-default-shell] [--no-packages]
  packages [--dry-run]
  ohmyzsh [--dry-run] [--profile <name>]
  plugins [--dry-run] [--profile <name>]
  configure [--dry-run] [--profile <name>]
  apply-user [--dry-run] [--profile <name>] [--request-file <path>]
  verify [--profile <name>]
  doctor [--profile <name>]
  test
  backups-list
  rollback --backup-file <path> [--target <path>] [--dry-run]
  clean-backups [--apply]
  chsh [--dry-run]
  help
EOF_USAGE
}

run_task() {
  local task=${1:?task is required}
  local resolved_profile=""
  local resolved_request_file=""
  shift || true

  resolved_profile="${DEV_ENV_PROFILE:-$DEFAULT_PROFILE}"
  resolved_request_file="${USER_REQUEST_FILE:-}"
  if [ -z "$resolved_request_file" ]; then
    resolved_request_file="$(resolve_request_file "$resolved_profile" "$DEFAULT_REQUEST_FILE")"
  fi

  PLUGINS_FILE="${PLUGINS_FILE:-$DEFAULT_PLUGINS_FILE}" \
    PLUGIN_LOCK_FILE="${PLUGIN_LOCK_FILE:-$DEFAULT_PLUGIN_LOCK_FILE}" \
    THEME_FILE="${THEME_FILE:-$DEFAULT_THEME_FILE}" \
    USER_REQUEST_FILE="$resolved_request_file" \
    DEV_ENV_PROFILE="$resolved_profile" \
    "$TASKS_DIR/$task" "$@"
}

packages_command() {
  local dry_run=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --help | -h)
        echo 'Usage: dev-env packages [--dry-run]'
        return 0
        ;;
      *)
        echo "Unknown packages option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" run_task install_packages.sh
}

ohmyzsh_command() {
  local dry_run=0 profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env ohmyzsh [--dry-run] [--profile <name>]'
        return 0
        ;;
      *)
        echo "Unknown ohmyzsh option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task install_ohmyzsh.sh
}

plugins_command() {
  local dry_run=0 profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env plugins [--dry-run] [--profile <name>]'
        return 0
        ;;
      *)
        echo "Unknown plugins option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task install_plugins.sh
}

configure_command() {
  local dry_run=0 profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env configure [--dry-run] [--profile <name>]'
        return 0
        ;;
      *)
        echo "Unknown configure option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task configure_zshrc.sh
}

apply_user_command() {
  local dry_run=0 request_file="" profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --request-file)
        shift
        request_file="${1:-}"
        [ -n "$request_file" ] || {
          echo '--request-file requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env apply-user [--dry-run] [--profile <name>] [--request-file <path>]'
        return 0
        ;;
      *)
        echo "Unknown apply-user option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" USER_REQUEST_FILE="$request_file" run_task apply_user_request.sh
}

verify_command() {
  local profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env verify [--profile <name>]'
        return 0
        ;;
      *)
        echo "Unknown verify option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_PROFILE="$profile" run_task verify.sh
}

doctor_command() {
  local profile="$DEFAULT_PROFILE"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env doctor [--profile <name>]'
        return 0
        ;;
      *)
        echo "Unknown doctor option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_PROFILE="$profile" run_task doctor.sh
}

rollback_command() {
  local backup_file='' rollback_target="${ROLLBACK_TARGET:-$HOME/.zshrc}" dry_run=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --backup-file)
        shift
        backup_file="${1:-}"
        [ -n "$backup_file" ] || {
          echo '--backup-file requires a value' >&2
          return 1
        }
        ;;
      --target)
        shift
        rollback_target="${1:-}"
        [ -n "$rollback_target" ] || {
          echo '--target requires a value' >&2
          return 1
        }
        ;;
      --dry-run)
        dry_run=1
        ;;
      --help | -h)
        echo 'Usage: dev-env rollback --backup-file <path> [--target <path>] [--dry-run]'
        return 0
        ;;
      *)
        echo "Unknown rollback option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  [ -n "$backup_file" ] || {
    echo 'rollback requires --backup-file <path>' >&2
    return 1
  }
  DEV_ENV_DRY_RUN="$dry_run" BACKUP_FILE="$backup_file" ROLLBACK_TARGET="$rollback_target" run_task backups.sh rollback
}

clean_backups_command() {
  local apply=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --apply)
        apply=1
        ;;
      --help | -h)
        echo 'Usage: dev-env clean-backups [--apply]'
        return 0
        ;;
      *)
        echo "Unknown clean-backups option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  APPLY="$apply" run_task backups.sh clean
}

chsh_command() {
  local dry_run=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=1
        ;;
      --help | -h)
        echo 'Usage: dev-env chsh [--dry-run]'
        return 0
        ;;
      *)
        echo "Unknown chsh option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  DEV_ENV_DRY_RUN="$dry_run" run_task change_shell.sh
}

bootstrap_command() {
  local set_default_shell=0 run_packages=1 dry_run=0 profile="$DEFAULT_PROFILE"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --set-default-shell)
        set_default_shell=1
        ;;
      --no-packages)
        run_packages=0
        ;;
      --dry-run)
        dry_run=1
        ;;
      --profile)
        shift
        profile="${1:-}"
        [ -n "$profile" ] || {
          echo '--profile requires a value' >&2
          return 1
        }
        ;;
      --help | -h)
        echo 'Usage: dev-env bootstrap [--profile <name>] [--dry-run] [--set-default-shell] [--no-packages]'
        return 0
        ;;
      *)
        echo "Unknown bootstrap option: $1" >&2
        return 1
        ;;
    esac
    shift || true
  done

  if [[ "$run_packages" -eq 1 ]]; then
    DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task install_packages.sh
  fi
  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task install_ohmyzsh.sh
  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task install_plugins.sh
  DEV_ENV_DRY_RUN="$dry_run" DEV_ENV_PROFILE="$profile" run_task configure_zshrc.sh

  if [[ "$dry_run" -eq 0 ]]; then
    DEV_ENV_PROFILE="$profile" run_task verify.sh
  else
    echo 'bootstrap dry-run complete. verify is skipped because no changes were applied.'
  fi

  if [[ "$set_default_shell" -eq 1 ]]; then
    DEV_ENV_DRY_RUN="$dry_run" run_task change_shell.sh
  fi

  echo 'bootstrap complete. apply now with: exec zsh'
}

if [[ $# -lt 1 ]]; then
  usage
  exit 0
fi

command_name="$1"
shift || true

case "$command_name" in
  help | -h | --help)
    usage
    ;;
  bootstrap)
    bootstrap_command "$@"
    ;;
  packages)
    packages_command "$@"
    ;;
  ohmyzsh)
    ohmyzsh_command "$@"
    ;;
  plugins)
    plugins_command "$@"
    ;;
  configure)
    configure_command "$@"
    ;;
  apply-user)
    apply_user_command "$@"
    ;;
  verify)
    verify_command "$@"
    ;;
  doctor)
    doctor_command "$@"
    ;;
  test)
    run_task test.sh "$@"
    ;;
  chsh)
    chsh_command "$@"
    ;;
  backups-list)
    run_task backups.sh list
    ;;
  rollback)
    rollback_command "$@"
    ;;
  clean-backups)
    clean_backups_command "$@"
    ;;
  *)
    echo "Unknown command: $command_name" >&2
    usage >&2
    exit 1
    ;;
esac
