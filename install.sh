#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME='envkit'
PREFIX="${PREFIX:-$HOME/.local}"
LIB_DIR=''
BIN_DIR=''
DRY_RUN=0

usage() {
  cat << 'EOF_USAGE'
Usage: ./install.sh [--prefix <path>] [--lib-dir <path>] [--bin-dir <path>] [--dry-run]
EOF_USAGE
}

run() {
  if [ "$DRY_RUN" = '1' ]; then
    printf '[dry-run]'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi
  "$@"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix)
      shift
      PREFIX="${1:-}"
      ;;
    --lib-dir)
      shift
      LIB_DIR="${1:-}"
      ;;
    --bin-dir)
      shift
      BIN_DIR="${1:-}"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift || true
done

[ -n "$PREFIX" ] || {
  echo '--prefix requires a value' >&2
  exit 1
}
LIB_DIR="${LIB_DIR:-$PREFIX/lib/$PACKAGE_NAME}"
BIN_DIR="${BIN_DIR:-$PREFIX/bin}"

run mkdir -p "$BIN_DIR"
if [ -e "$LIB_DIR" ]; then
  run rm -rf "$LIB_DIR"
fi
run mkdir -p "$LIB_DIR"
run cp -a "$ROOT_DIR/README.md" "$ROOT_DIR/LICENSE" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/project_manual.md" "$ROOT_DIR/config" "$ROOT_DIR/docs" "$ROOT_DIR/resources" "$ROOT_DIR/scripts" "$LIB_DIR/"

wrapper_tmp="$(mktemp)"
trap 'rm -f "$wrapper_tmp"' EXIT
cat > "$wrapper_tmp" << EOF_WRAPPER
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="\$(cd "\$SCRIPT_DIR/../lib/$PACKAGE_NAME" && pwd)"
exec "\$INSTALL_ROOT/scripts/envkit.sh" "\$@"
EOF_WRAPPER
run cp "$wrapper_tmp" "$BIN_DIR/$PACKAGE_NAME"
run chmod +x "$BIN_DIR/$PACKAGE_NAME"

echo "Installed $PACKAGE_NAME"
echo "  lib: $LIB_DIR"
echo "  bin: $BIN_DIR/$PACKAGE_NAME"
