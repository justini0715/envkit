#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="${ENVKIT_TOOLS_DIR:-$ROOT_DIR/.cache/envkit-tools/bin}"
SHELLCHECK_VERSION="${SHELLCHECK_VERSION:-v0.11.0}"
SHFMT_VERSION="${SHFMT_VERSION:-v3.11.0}"

print_bin_dir() {
  printf '%s\n' "$TOOLS_DIR"
}

fetch_shellcheck() {
  local tmp_dir archive_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN
  curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" -o "$tmp_dir/shellcheck.tar.xz"
  tar -xJf "$tmp_dir/shellcheck.tar.xz" -C "$tmp_dir"
  archive_dir="$tmp_dir/shellcheck-${SHELLCHECK_VERSION}"
  install -m 0755 "$archive_dir/shellcheck" "$TOOLS_DIR/shellcheck"
}

fetch_shfmt() {
  curl -fsSL "https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64" -o "$TOOLS_DIR/shfmt"
  chmod +x "$TOOLS_DIR/shfmt"
}

mkdir -p "$TOOLS_DIR"

if [ ! -x "$TOOLS_DIR/shellcheck" ]; then
  fetch_shellcheck
fi

if [ ! -x "$TOOLS_DIR/shfmt" ]; then
  fetch_shfmt
fi

if [ "${1:-}" = '--print-bin-dir' ]; then
  print_bin_dir
  exit 0
fi

print_bin_dir
