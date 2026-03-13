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

write_shim sudo << 'EOF_SUDO'
#!/usr/bin/env bash
set -euo pipefail
exec "$@"
EOF_SUDO

write_shim apt-get << 'EOF_APT'
#!/usr/bin/env bash
set -euo pipefail
printf 'apt-get %s\n' "$*" >>"${DEV_ENV_TEST_LOG:-/tmp/dev-env-apt.log}"
EOF_APT

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
#!/usr/bin/env bash
set -euo pipefail
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
  repo=''
  dir=''
  for arg in "$@"; do
    repo="$dir"
    dir="$arg"
  done
  mkdir -p "$dir/.git"
  printf '%s\n' "${repo:-test-repo}" >"$dir/.git/source.txt"
  exit 0
fi
if [[ ${1:-} == '-C' ]]; then
  exit 0
fi
exit 0
EOF_GIT

write_shim zsh << 'EOF_ZSH'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == '--version' ]]; then
  echo 'zsh 5.9 test'
  exit 0
fi
exit 0
EOF_ZSH

write_shim gcc << 'EOF_GCC'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == '--version' ]]; then
  echo 'gcc (test) 14.0'
  exit 0
fi
exit 0
EOF_GCC

write_shim chsh << 'EOF_CHSH'
#!/usr/bin/env bash
set -euo pipefail
printf 'chsh %s\n' "$*" >>"${DEV_ENV_TEST_LOG:-/tmp/dev-env-chsh.log}"
EOF_CHSH

assert_file_exists() {
  local file=${1:?file is required}
  [ -f "$file" ] || {
    echo "[test] missing file: $file" >&2
    exit 1
  }
}

assert_contains() {
  local file=${1:?file is required}
  local pattern=${2:?pattern is required}
  grep -Fq "$pattern" "$file" || {
    echo "[test] expected pattern not found: $pattern (file: $file)" >&2
    exit 1
  }
}

assert_not_contains() {
  local file=${1:?file is required}
  local pattern=${2:?pattern is required}
  if grep -Fq "$pattern" "$file"; then
    echo "[test] unexpected pattern found: $pattern (file: $file)" >&2
    exit 1
  fi
}

TEST_ENV=(
  PATH="$FAKE_BIN:$PATH"
  HOME="$TEST_HOME"
  SHELL="/bin/bash"
  DEV_ENV_TEST_LOG="$TMP_ROOT/test.log"
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

# init-zsh
clear
python3 ~/.bg.py
ls
EOF_ZSHRC

echo '[test] bootstrap dry-run smoke'
env "${TEST_ENV[@]}" ./dev-env bootstrap --dry-run --no-packages --profile minimal > /dev/null

echo '[test] packages dry-run'
packages_output="$(env "${TEST_ENV[@]}" ./dev-env packages --dry-run)"
[[ "$packages_output" == *"apt-get"* ]] || {
  echo '[test] packages dry-run missing apt-get output' >&2
  exit 1
}

echo '[test] bootstrap actual on temp HOME'
env "${TEST_ENV[@]}" ./dev-env bootstrap --no-packages --profile general-dev > /dev/null

assert_file_exists "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh"
assert_file_exists "$TEST_HOME/.config/zsh/conf.d/10-dev-env-ohmyzsh.zsh"
assert_file_exists "$TEST_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/.git/source.txt"
assert_file_exists "$TEST_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git/source.txt"
assert_file_exists "$TEST_HOME/.oh-my-zsh/custom/plugins/zsh-completions/.git/source.txt"
assert_not_contains "$TEST_HOME/.zshrc" '# init-zsh'
assert_not_contains "$TEST_HOME/.zshrc" 'python3 ~/.bg.py'
assert_not_contains "$TEST_HOME/.zshrc" 'ls'
assert_contains "$TEST_HOME/.config/zsh/conf.d/10-dev-env-ohmyzsh.zsh" 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)'
assert_contains "$TEST_HOME/.config/zsh/conf.d/10-dev-env-ohmyzsh.zsh" 'ZSH_THEME="robbyrussell"'

echo '[test] configure idempotency'
backup_count_before="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.dev-env.bak.*' | wc -l | tr -d ' ')"
env "${TEST_ENV[@]}" ./dev-env configure --profile general-dev > /dev/null
backup_count_after="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.dev-env.bak.*' | wc -l | tr -d ' ')"
if [ "$backup_count_before" != "$backup_count_after" ]; then
  echo '[test] configure idempotency failed (backup count changed).' >&2
  exit 1
fi

echo '[test] apply-user parsing'
USER_REQUEST_TEXT_INPUT=$(
  cat << 'EOF_REQ'
plugins: git zsh-autosuggestions
theme: agnoster
aliases: ll='ls -al'
init: export EDITOR=vim
EOF_REQ
)
env "${TEST_ENV[@]}" \
  USER_REQUEST_TEXT="$USER_REQUEST_TEXT_INPUT" \
  PLUGINS_FILE="$TMP_ROOT/plugins.txt" \
  THEME_FILE="$TMP_ROOT/theme.txt" \
  USER_CONF_TARGET="$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" \
  "$ROOT_DIR/scripts/tasks/apply_user_request.sh" > /dev/null

assert_contains "$TMP_ROOT/plugins.txt" 'git'
assert_contains "$TMP_ROOT/plugins.txt" 'zsh-autosuggestions'
assert_contains "$TMP_ROOT/theme.txt" 'agnoster'
assert_contains "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" "alias ll='ls -al'"
assert_contains "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" 'export EDITOR=vim'

echo '[test] personal profile opt-in'
rm -f "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh"
env "${TEST_ENV[@]}" ./dev-env configure --profile personal > /dev/null
assert_contains "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" 'clear'
assert_contains "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" 'python3 ~/.bg.py'
assert_contains "$TEST_HOME/.config/zsh/conf.d/30-dev-env-user.zsh" 'ls'

echo '[test] verify + doctor on temp HOME'
env "${TEST_ENV[@]}" ./dev-env verify --profile general-dev > /dev/null
env "${TEST_ENV[@]}" ./dev-env doctor --profile general-dev > /dev/null

echo '[test] backups list + rollback + clean'
latest_backup="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.dev-env.bak.*' | sort | tail -n 1)"
[ -n "$latest_backup" ] || {
  echo '[test] expected at least one backup file' >&2
  exit 1
}
list_output="$(env "${TEST_ENV[@]}" ./dev-env backups-list)"
[[ "$list_output" == *'.dev-env.bak.'* ]] || {
  echo '[test] backups-list missing backup output' >&2
  exit 1
}
rollback_target="$TMP_ROOT/rollback-target.zshrc"
env "${TEST_ENV[@]}" ./dev-env rollback --backup-file "$latest_backup" --target "$rollback_target" > /dev/null
assert_file_exists "$rollback_target"
clean_output="$(env "${TEST_ENV[@]}" ./dev-env clean-backups)"
[[ "$clean_output" == *'[dry-run]'* ]] || {
  echo '[test] clean-backups dry-run output missing' >&2
  exit 1
}
env "${TEST_ENV[@]}" APPLY=1 "$ROOT_DIR/scripts/tasks/backups.sh" clean > /dev/null
remaining_backups="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.dev-env.bak.*' | wc -l | tr -d ' ')"
[ "$remaining_backups" = '0' ] || {
  echo '[test] expected backups to be removed' >&2
  exit 1
}

echo '[test] chsh dry-run'
chsh_output="$(env "${TEST_ENV[@]}" ./dev-env chsh --dry-run)"
[[ "$chsh_output" == *'[dry-run]'* ]] || {
  echo '[test] chsh dry-run output missing' >&2
  exit 1
}

echo '[ok] Phase 2 temp-environment integration passed'
