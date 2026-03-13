#!/usr/bin/env bash
set -euo pipefail

ZSHRC=${ZSHRC:-"$HOME/.zshrc"}
ZSH_CONF_DIR=${ZSH_CONF_DIR:-"$HOME/.config/zsh/conf.d"}
BACKUP_FILE=${BACKUP_FILE:-""}
ROLLBACK_TARGET=${ROLLBACK_TARGET:-"$ZSHRC"}
APPLY=${APPLY:-0}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

collect_backup_files() {
  local pattern file
  local -a patterns=(
    "$ZSHRC.dev-env.bak.*"
    "$ZSH_CONF_DIR/*.dev-env.bak.*"
    "$HOME/.bg.py.dev-env.bak.*"
    "$HOME/.printbg.py.dev-env.bak.*"
  )

  for pattern in "${patterns[@]}"; do
    while IFS= read -r file; do
      [ -n "$file" ] && printf '%s
' "$file"
    done < <(compgen -G "$pattern" || true)
  done
}

usage() {
  cat << 'EOF_USAGE'
Usage: scripts/tasks/backups.sh <list|rollback|clean>
EOF_USAGE
}

[ "$#" -ge 1 ] || {
  usage >&2
  exit 1
}
command_name="$1"

case "$command_name" in
  list)
    mapfile -t backups < <(collect_backup_files | sort -r)
    if [ "${#backups[@]}" -eq 0 ]; then
      echo 'No dev-env backup files found.'
      exit 0
    fi
    printf '%s
' "${backups[@]}"
    ;;
  rollback)
    [ -n "$BACKUP_FILE" ] || die 'rollback requires BACKUP_FILE'
    [ -f "$BACKUP_FILE" ] || die "backup file not found: $BACKUP_FILE"
    case "$BACKUP_FILE" in
      *.dev-env.bak.*) ;;
      *) die "refusing rollback from non dev-env backup file: $BACKUP_FILE" ;;
    esac
    if is_dry_run; then
      echo "[dry-run] cp $BACKUP_FILE $ROLLBACK_TARGET"
      exit 0
    fi
    mkdir -p "$(dirname "$ROLLBACK_TARGET")"
    cp "$BACKUP_FILE" "$ROLLBACK_TARGET"
    echo "Restored $ROLLBACK_TARGET from $BACKUP_FILE"
    ;;
  clean)
    mapfile -t backups < <(collect_backup_files | sort -r)
    if [ "${#backups[@]}" -eq 0 ]; then
      echo 'No dev-env backup files found.'
      exit 0
    fi
    if [ "$APPLY" != '1' ]; then
      echo '[dry-run] backup files to remove (set APPLY=1 to delete):'
      printf '%s
' "${backups[@]}"
      exit 0
    fi
    rm -f -- "${backups[@]}"
    echo "Removed ${#backups[@]} backup file(s)."
    ;;
  *)
    echo "Unknown backups command: $command_name" >&2
    usage >&2
    exit 1
    ;;
esac
