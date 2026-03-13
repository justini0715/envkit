#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION_INPUT=${1:-${VERSION:-"0.1.0"}}
PACKAGE_NAME=${PACKAGE_NAME:-"dev-env"}
PACKAGE_ARCH=${PACKAGE_ARCH:-"all"}
OUTPUT_DIR=${OUTPUT_DIR:-"$ROOT_DIR/dist/deb"}
MAINTAINER=${MAINTAINER:-"dev-env maintainer <devnull@example.com>"}
PACKAGE_DEPENDS=${PACKAGE_DEPENDS:-"bash, ca-certificates, curl, git, zsh"}
PACKAGE_RECOMMENDS=${PACKAGE_RECOMMENDS:-"build-essential"}
PACKAGE_SUGGESTS=${PACKAGE_SUGGESTS:-"apt-utils, dpkg-dev, gnupg, gh"}

VERSION="$(printf '%s' "$VERSION_INPUT" | tr -d '\r\n')"
VERSION="${VERSION#v}"

if ! command -v dpkg-deb > /dev/null 2>&1; then
  echo "dpkg-deb not found. Install dpkg." >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9] ]]; then
  echo "Invalid deb version: '$VERSION_INPUT' (normalized: '$VERSION')" >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9A-Za-z.+:~-]+$ ]]; then
  echo "Invalid deb version: $VERSION" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

pkg_root="$tmp_dir/pkgroot"
install_root="$pkg_root/usr/lib/$PACKAGE_NAME"
mkdir -p "$install_root" "$pkg_root/usr/bin" "$pkg_root/DEBIAN"

cp -a \
  "$ROOT_DIR/README.md" \
  "$ROOT_DIR/LICENSE" \
  "$ROOT_DIR/AGENTS.md" \
  "$ROOT_DIR/project_manual.md" \
  "$ROOT_DIR/install.sh" \
  "$ROOT_DIR/config" \
  "$ROOT_DIR/docs" \
  "$ROOT_DIR/resources" \
  "$ROOT_DIR/scripts" \
  "$install_root/"

cat > "$pkg_root/usr/bin/$PACKAGE_NAME" << EOF_WRAPPER
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="\$(cd "\$SCRIPT_DIR/../lib/$PACKAGE_NAME" && pwd)"
exec "\$INSTALL_ROOT/scripts/dev-env.sh" "\$@"
EOF_WRAPPER
chmod +x "$pkg_root/usr/bin/$PACKAGE_NAME"

{
  echo "Package: $PACKAGE_NAME"
  echo "Version: $VERSION"
  echo "Section: utils"
  echo "Priority: optional"
  echo "Architecture: $PACKAGE_ARCH"
  echo "Maintainer: $MAINTAINER"
  echo "Depends: $PACKAGE_DEPENDS"
  [ -n "$PACKAGE_RECOMMENDS" ] && echo "Recommends: $PACKAGE_RECOMMENDS"
  [ -n "$PACKAGE_SUGGESTS" ] && echo "Suggests: $PACKAGE_SUGGESTS"
  echo "Description: standalone Debian/Ubuntu zsh bootstrap CLI"
  echo " Product-first release artifact for dev-env."
  echo " Includes bootstrap/configure/verify/doctor/rollback helpers and"
  echo " packaging/release documentation for the standalone repository layout."
} > "$pkg_root/DEBIAN/control"

mkdir -p "$OUTPUT_DIR"
deb_file="$OUTPUT_DIR/${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb"
dpkg-deb --root-owner-group --build "$pkg_root" "$deb_file" > /dev/null

echo "Built package: $deb_file"
