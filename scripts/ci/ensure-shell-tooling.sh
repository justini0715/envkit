#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="${ENVKIT_TOOLS_DIR:-$ROOT_DIR/.cache/envkit-tools/bin}"
SHELLCHECK_VERSION="${SHELLCHECK_VERSION:-v0.11.0}"
SHFMT_VERSION="${SHFMT_VERSION:-v3.11.0}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"

print_bin_dir() {
  printf '%s\n' "$TOOLS_DIR"
}

link_existing_tool() {
  local tool_name=${1:?tool_name is required}
  local existing_tool

  existing_tool="$(command -v "$tool_name" || true)"
  if [ -n "$existing_tool" ]; then
    ln -sf "$existing_tool" "$TOOLS_DIR/$tool_name"
    return 0
  fi
  return 1
}

fetch_shellcheck_linux() {
  local tmp_dir archive_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN
  curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" -o "$tmp_dir/shellcheck.tar.xz"
  tar -xJf "$tmp_dir/shellcheck.tar.xz" -C "$tmp_dir"
  archive_dir="$tmp_dir/shellcheck-${SHELLCHECK_VERSION}"
  install -m 0755 "$archive_dir/shellcheck" "$TOOLS_DIR/shellcheck"
}

fetch_shfmt_linux() {
  curl -fsSL "https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64" -o "$TOOLS_DIR/shfmt"
  chmod +x "$TOOLS_DIR/shfmt"
}

ensure_macos_tooling() {
  if ! command -v brew > /dev/null 2>&1; then
    echo "Homebrew not found. Install shellcheck and shfmt with Homebrew on macOS." >&2
    exit 1
  fi

  brew list shellcheck > /dev/null 2>&1 || brew install shellcheck
  brew list shfmt > /dev/null 2>&1 || brew install shfmt
  link_existing_tool shellcheck
  link_existing_tool shfmt
}

mkdir -p "$TOOLS_DIR"

if [ "$PLATFORM" = "darwin" ]; then
  ensure_macos_tooling
else
  if [ ! -x "$TOOLS_DIR/shellcheck" ] && ! link_existing_tool shellcheck; then
    fetch_shellcheck_linux
  fi

  if [ ! -x "$TOOLS_DIR/shfmt" ] && ! link_existing_tool shfmt; then
    fetch_shfmt_linux
  fi
fi

if [ "${1:-}" = '--print-bin-dir' ]; then
  print_bin_dir
  exit 0
fi

print_bin_dir
