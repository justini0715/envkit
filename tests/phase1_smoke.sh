#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

syntax_paths=(
  dev-env
  scripts/*.sh
  scripts/tasks/*.sh
  tests/*.sh
  tests/smoke/*.sh
)

bash -n "${syntax_paths[@]}"
echo '[ok] bash syntax checks passed'

./tests/smoke/phase1-structure.sh

echo '[ok] foundation smoke checks passed'
