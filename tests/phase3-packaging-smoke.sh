#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${VERSION:-0.3.0-test}"
DEB_OUTPUT_DIR="${DEB_OUTPUT_DIR:-$ROOT_DIR/dist/deb}"
APT_OUTPUT_DIR="${APT_OUTPUT_DIR:-$ROOT_DIR/dist/apt-test}"
TMP_ROOT="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

bash -n envkit scripts/*.sh scripts/tasks/*.sh packaging/*.sh install.sh tests/*.sh tests/smoke/*.sh

./envkit test > /dev/null
./packaging/build-deb.sh "$VERSION" > /dev/null

deb_file="$DEB_OUTPUT_DIR/envkit_${VERSION}_all.deb"
[ -f "$deb_file" ] || {
  echo "missing deb artifact: $deb_file" >&2
  exit 1
}

dpkg-deb -I "$deb_file" > "$TMP_ROOT/control.txt"
grep -q 'Package: envkit' "$TMP_ROOT/control.txt"
grep -q 'Depends: bash, ca-certificates, curl, git, zsh' "$TMP_ROOT/control.txt"
grep -q 'Recommends: build-essential' "$TMP_ROOT/control.txt"

dpkg-deb -c "$deb_file" > "$TMP_ROOT/contents.txt"
grep -q '/usr/bin/envkit' "$TMP_ROOT/contents.txt"
grep -q '/usr/lib/envkit/scripts/envkit.sh' "$TMP_ROOT/contents.txt"
grep -q '/usr/lib/envkit/install.sh' "$TMP_ROOT/contents.txt"

extract_dir="$TMP_ROOT/extract"
dpkg-deb -x "$deb_file" "$extract_dir"
"$extract_dir/usr/bin/envkit" help > "$TMP_ROOT/package-help.txt"
grep -q 'bootstrap' "$TMP_ROOT/package-help.txt"

authless_apt_dir="$APT_OUTPUT_DIR"
rm -rf "$authless_apt_dir"
./packaging/build-apt-repo.sh "$deb_file" "$authless_apt_dir" stable > /dev/null
[ -f "$authless_apt_dir/index.html" ] || {
  echo 'missing Pages index.html' >&2
  exit 1
}
[ -f "$authless_apt_dir/dists/stable/Release" ] || {
  echo 'missing Release file' >&2
  exit 1
}
[ -f "$authless_apt_dir/dists/stable/main/binary-amd64/Packages" ] || {
  echo 'missing Packages file' >&2
  exit 1
}
[ -f "$authless_apt_dir/dists/stable/main/binary-amd64/Packages.gz" ] || {
  echo 'missing Packages.gz file' >&2
  exit 1
}
grep -q 'envkit APT Repository' "$authless_apt_dir/index.html"
grep -q 'sudo apt install -y envkit' "$authless_apt_dir/index.html"

prefix_dir="$TMP_ROOT/prefix"
./install.sh --prefix "$prefix_dir" > /dev/null
[ -x "$prefix_dir/bin/envkit" ] || {
  echo 'missing installed wrapper' >&2
  exit 1
}
"$prefix_dir/bin/envkit" help > "$TMP_ROOT/install-help.txt"
grep -q 'bootstrap' "$TMP_ROOT/install-help.txt"

grep -q 'Phase 3 — Packaging and Release' docs/architecture/implementation-plan.md
grep -q 'Packaging and Release' docs/adr/0003-packaging-and-release-strategy.md
grep -qi 'release checklist' docs/checklists/release-checklist.md
[ -f .github/workflows/publish-apt-repo.yml ] || {
  echo 'missing publish workflow' >&2
  exit 1
}

echo '[ok] Phase 3 packaging smoke passed'
echo "[artifact] $deb_file"
echo "[artifact] $authless_apt_dir"
