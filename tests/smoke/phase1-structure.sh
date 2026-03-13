#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  README.md
  AGENTS.md
  project_manual.md
  Makefile
  .gitignore
  .shellcheckrc
  install.sh
  envkit
  scripts/envkit.sh
  scripts/main.sh
  scripts/lib.sh
  scripts/ci/ensure-shell-tooling.sh
  scripts/ci/lint.sh
  scripts/ci/format-check.sh
  scripts/ci/format.sh
  docs/architecture/implementation-plan.md
  docs/adr/0001-product-repo-structure.md
  docs/adr/0002-safe-shell-init-defaults.md
  docs/adr/0003-packaging-and-release-strategy.md
  docs/runbooks/local-setup.md
  docs/runbooks/recovery-and-rollback.md
  docs/runbooks/troubleshooting.md
  docs/runbooks/developer-guide.md
  docs/checklists/release-checklist.md
  docs/release-notes-template.md
  .omx/plans/prd-phase1-product-foundation.md
  .omx/plans/test-spec-phase1-product-foundation.md
  .omx/plans/prd-phase2-cli-hardening.md
  .omx/plans/test-spec-phase2-cli-hardening.md
  .omx/plans/prd-phase3-packaging-release.md
  .omx/plans/test-spec-phase3-packaging-release.md
  .omx/plans/prd-phase4-hardening.md
  .omx/plans/test-spec-phase4-hardening.md
  config/profiles/minimal.env
  config/profiles/general-dev.env
  config/profiles/cpp-42.env
  config/profiles/personal.env
  config/user/personal-request.txt
  packaging/build-deb.sh
  packaging/build-apt-repo.sh
  packaging/generate-gpg-key.sh
  packaging/github-secrets-apply.sh
  tests/phase3-packaging-smoke.sh
  tests/macos_experimental_smoke.sh
  .github/workflows/ci.yml
  .github/workflows/publish-apt-repo.yml
)

required_dirs=(
  config/zsh
  config/user
  config/profiles
  docs/adr
  docs/runbooks
  docs/checklists
  packaging
  resources
  scripts/tasks
  scripts/ci
  tests
  tests/smoke
  .github/workflows
)

for path in "${required_files[@]}"; do
  [ -f "$path" ] || {
    echo "missing file: $path" >&2
    exit 1
  }
done

for path in "${required_dirs[@]}"; do
  [ -d "$path" ] || {
    echo "missing directory: $path" >&2
    exit 1
  }
done

for path in envkit install.sh scripts/envkit.sh scripts/main.sh scripts/lib.sh scripts/ci/ensure-shell-tooling.sh scripts/ci/lint.sh scripts/ci/format-check.sh scripts/ci/format.sh tests/phase1_smoke.sh tests/phase2_integration.sh tests/phase3-packaging-smoke.sh tests/macos_experimental_smoke.sh tests/smoke/phase1-structure.sh tests/smoke/phase2-cli-smoke.sh packaging/build-deb.sh packaging/build-apt-repo.sh packaging/generate-gpg-key.sh packaging/github-secrets-apply.sh; do
  [ -x "$path" ] || {
    echo "missing executable bit: $path" >&2
    exit 1
  }
done

branch_name="$(git branch --show-current)"
case "$branch_name" in
  main | master)
    if [ "${CI:-}" != "true" ]; then
      echo "branch policy violated: $branch_name" >&2
      exit 1
    fi
    ;;
esac

grep -q 'Phase 4 — Hardening and Polish' docs/architecture/implementation-plan.md
grep -q 'do not develop directly on' docs/runbooks/developer-guide.md

echo '[ok] structure checks passed'
