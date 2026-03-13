#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_BIN="$("$ROOT_DIR"/scripts/ci/ensure-shell-tooling.sh --print-bin-dir)"
PATH="$TOOLS_BIN:$PATH"
cd "$ROOT_DIR"

shell_files=()
while IFS= read -r file; do
  shell_files+=("$file")
done < <(
  find . -type f -name '*.sh' \
    -not -path './.git/*' \
    -not -path './dist/*' \
    -not -path './.cache/*' |
    sort
)

shfmt -i 2 -ci -sr -w "${shell_files[@]}"
