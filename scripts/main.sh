#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"

usage() {
  cat << 'EOF_USAGE'
Usage: scripts/main.sh <task> [args...]

Tasks:
  install-packages   (aliases: install_packages, packages)
  install-ohmyzsh    (aliases: install_ohmyzsh, ohmyzsh)
  install-plugins    (aliases: install_plugins, plugins)
  configure          (aliases: configure_zshrc, configure-zshrc)
  apply-user         (aliases: apply_user, apply-user-request, apply_user_request)
  doctor
  test
  backups            (aliases: backup)
  change-shell       (aliases: change_shell, chsh)
  verify
EOF_USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 0
fi

task_input="$1"
shift || true

case "$task_input" in
  help | -h | --help)
    usage
    exit 0
    ;;
  install-packages | install_packages | packages)
    task_script="$TASKS_DIR/install_packages.sh"
    ;;
  install-ohmyzsh | install_ohmyzsh | ohmyzsh)
    task_script="$TASKS_DIR/install_ohmyzsh.sh"
    ;;
  install-plugins | install_plugins | plugins)
    task_script="$TASKS_DIR/install_plugins.sh"
    ;;
  configure | configure_zshrc | configure-zshrc)
    task_script="$TASKS_DIR/configure_zshrc.sh"
    ;;
  apply-user | apply_user | apply-user-request | apply_user_request)
    task_script="$TASKS_DIR/apply_user_request.sh"
    ;;
  doctor)
    task_script="$TASKS_DIR/doctor.sh"
    ;;
  test)
    task_script="$TASKS_DIR/test.sh"
    ;;
  backups | backup)
    task_script="$TASKS_DIR/backups.sh"
    ;;
  change-shell | change_shell | chsh)
    task_script="$TASKS_DIR/change_shell.sh"
    ;;
  verify)
    task_script="$TASKS_DIR/verify.sh"
    ;;
  *)
    echo "Unknown task: $task_input" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ ! -f "$task_script" ]]; then
  echo "Task script not found: $task_script" >&2
  exit 1
fi

exec "$task_script" "$@"
