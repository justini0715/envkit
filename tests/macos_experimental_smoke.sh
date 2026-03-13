#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TMP_ROOT="$(mktemp -d)"
FAKE_BIN="$TMP_ROOT/bin"
TEST_HOME="$TMP_ROOT/home"
mkdir -p "$FAKE_BIN" "$TEST_HOME/.config/zsh/conf.d"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

write_shim() {
  local name=${1:?name is required}
  shift
  cat > "$FAKE_BIN/$name"
  chmod +x "$FAKE_BIN/$name"
}

write_shim brew << 'EOF_BREW'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == 'list' ]]; then
  exit 0
fi
printf 'brew %s\n' "$*" >>"${ENVKIT_TEST_LOG:-/tmp/envkit-brew.log}"
exit 0
EOF_BREW

write_shim curl << 'EOF_CURL'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == '--version' ]]; then
  echo 'curl 9.9.9 test'
  exit 0
fi
output=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      shift
      output="${1:-}"
      ;;
  esac
  shift || true
done
[ -n "$output" ] || exit 1
cat >"$output" <<'SCRIPT'
#!/bin/sh
set -eu
mkdir -p "$ZSH/plugins/git" "$ZSH/custom/plugins"
printf '# fake oh-my-zsh\n' >"$ZSH/oh-my-zsh.sh"
SCRIPT
chmod +x "$output"
EOF_CURL

write_shim git << 'EOF_GIT'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == '--version' ]]; then
  echo 'git version 2.99.test'
  exit 0
fi
if [[ ${1:-} == 'clone' ]]; then
  dir="${@: -1}"
  mkdir -p "$dir/.git"
  exit 0
fi
if [[ ${1:-} == '-C' ]]; then
  exit 0
fi
exit 0
EOF_GIT

for name in zsh cc chsh; do
  write_shim "$name" << 'EOF_TOOL'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == '--version' ]]; then
  echo 'tool version test'
  exit 0
fi
exit 0
EOF_TOOL
done

TEST_ENV=(
  PATH="$FAKE_BIN:$PATH"
  HOME="$TEST_HOME"
  SHELL="/bin/bash"
  ENVKIT_TEST_LOG="$TMP_ROOT/test.log"
  ENVKIT_PLATFORM_OVERRIDE="darwin"
  ZSHRC="$TEST_HOME/.zshrc"
  ZSH_DIR="$TEST_HOME/.oh-my-zsh"
  ZSH_CONF_DIR="$TEST_HOME/.config/zsh/conf.d"
  PLUGINS_FILE="$ROOT_DIR/config/zsh/plugins.txt"
  PLUGIN_LOCK_FILE="$ROOT_DIR/config/zsh/plugin-lock.txt"
  THEME_FILE="$ROOT_DIR/config/zsh/theme.txt"
  USER_REQUEST_FILE=
)

cat > "$TEST_HOME/.zshrc" << 'EOF_ZSHRC'
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"
EOF_ZSHRC

echo '[test] macOS packages dry-run'
packages_output="$(env "${TEST_ENV[@]}" ./envkit packages --dry-run)"
[[ "$packages_output" == *'brew'* ]] || {
  echo '[test] macOS packages dry-run missing brew output' >&2
  exit 1
}

echo '[test] macOS bootstrap actual on temp HOME'
env "${TEST_ENV[@]}" ./envkit bootstrap --profile minimal > /dev/null

[ -f "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh" ] || {
  echo '[test] missing oh-my-zsh install on macOS path' >&2
  exit 1
}
[ -f "$TEST_HOME/.config/zsh/conf.d/10-envkit-ohmyzsh.zsh" ] || {
  echo '[test] missing managed zsh config on macOS path' >&2
  exit 1
}

echo '[test] macOS verify + doctor'
env "${TEST_ENV[@]}" ./envkit verify --profile minimal > /dev/null
env "${TEST_ENV[@]}" ./envkit doctor --profile minimal > /dev/null

echo '[test] macOS configure dry-run'
configure_output="$(env "${TEST_ENV[@]}" ./envkit configure --dry-run --profile personal)"
[[ "$configure_output" == *'Resolved theme'* ]] || {
  echo '[test] macOS configure dry-run missing expected output' >&2
  exit 1
}

echo '[ok] macOS experimental smoke passed'
