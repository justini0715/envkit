#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

SMOKE_HOME="$tmp_dir/home"
mkdir -p "$SMOKE_HOME/.config/zsh/conf.d"
SMOKE_ENV=(
  HOME="$SMOKE_HOME"
  SHELL="/bin/bash"
  ZSHRC="$SMOKE_HOME/.zshrc"
  ZSH_DIR="$SMOKE_HOME/.oh-my-zsh"
  ZSH_CONF_DIR="$SMOKE_HOME/.config/zsh/conf.d"
)

make help > "$tmp_dir/make-help.txt"
grep -q 'Phase 4 Hardening and Polish' "$tmp_dir/make-help.txt"
grep -q 'make verify' "$tmp_dir/make-help.txt"
grep -q './dev-env test' "$tmp_dir/make-help.txt"
grep -q 'make package-deb' "$tmp_dir/make-help.txt"

./dev-env help > "$tmp_dir/dev-env-help.txt"
grep -q 'bootstrap' "$tmp_dir/dev-env-help.txt"
grep -q 'doctor' "$tmp_dir/dev-env-help.txt"

./scripts/main.sh help > "$tmp_dir/main-help.txt"
grep -q 'install-packages' "$tmp_dir/main-help.txt"
grep -q 'verify' "$tmp_dir/main-help.txt"

env "${SMOKE_ENV[@]}" ./dev-env bootstrap --dry-run --no-packages --profile minimal > "$tmp_dir/bootstrap.txt"
grep -q 'bootstrap dry-run complete' "$tmp_dir/bootstrap.txt"
grep -q 'bootstrap complete' "$tmp_dir/bootstrap.txt"

env "${SMOKE_ENV[@]}" ./dev-env packages --dry-run > "$tmp_dir/packages.txt"
grep -q '\[dry-run\]' "$tmp_dir/packages.txt"
grep -q 'apt-get' "$tmp_dir/packages.txt"

env "${SMOKE_ENV[@]}" ./dev-env ohmyzsh --dry-run --profile general-dev > "$tmp_dir/ohmyzsh.txt"
grep -q 'Would install Oh My Zsh' "$tmp_dir/ohmyzsh.txt"

env "${SMOKE_ENV[@]}" ./dev-env plugins --dry-run --profile general-dev > "$tmp_dir/plugins.txt"
grep -q '\[dry-run\]' "$tmp_dir/plugins.txt"

env "${SMOKE_ENV[@]}" ./dev-env configure --dry-run --profile minimal > "$tmp_dir/configure.txt"
grep -q 'Configured' "$tmp_dir/configure.txt"

env "${SMOKE_ENV[@]}" ./dev-env chsh --dry-run > "$tmp_dir/chsh.txt"
grep -q '\[dry-run\]' "$tmp_dir/chsh.txt"

./dev-env apply-user --help > "$tmp_dir/apply-user-help.txt"
grep -q 'Usage: dev-env apply-user' "$tmp_dir/apply-user-help.txt"

./dev-env rollback --help > "$tmp_dir/rollback-help.txt"
grep -q 'Usage: dev-env rollback' "$tmp_dir/rollback-help.txt"

./dev-env clean-backups --help > "$tmp_dir/clean-help.txt"
grep -q 'Usage: dev-env clean-backups' "$tmp_dir/clean-help.txt"

echo '[ok] Phase 4 CLI smoke checks passed'
