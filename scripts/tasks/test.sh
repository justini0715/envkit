#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

"$ROOT_DIR/tests/phase1_smoke.sh"
"$ROOT_DIR/tests/smoke/phase2-cli-smoke.sh"
"$ROOT_DIR/tests/phase2_integration.sh"
"$ROOT_DIR/tests/macos_experimental_smoke.sh"

echo '[ok] Phase 2 + macOS experimental test suite passed'
