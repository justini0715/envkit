# PRD — Phase 2 CLI Hardening

## Phase
- Phase 2 — CLI Hardening
- Branch: `feat/phase2-cli-hardening`

## Objective
Turn the Phase 1 scaffold into a reliable local CLI for bootstrap, configure, verification, diagnostics, and rollback flows while keeping dangerous defaults opt-in and preserving a product-first repo structure.

## Problem Statement
Phase 1 established routing and docs only. Phase 2 must replace those placeholders with real shell behavior for the local CLI core, while avoiding unsafe startup defaults and keeping verification reproducible without mutating the developer's real machine during tests.

## In Scope
- real implementations for `bootstrap`, `packages`, `ohmyzsh`, `plugins`, `configure`, `apply-user`, `verify`, `doctor`, `test`, `backups-list`, `rollback`, `clean-backups`, and `chsh`
- `--dry-run` support where practical
- named profile support (`minimal`, `general-dev`, `cpp-42`) for plugin/theme defaults
- safe zsh configuration behavior with no forced `clear`, `python3 ~/.bg.py`, or `ls`
- expanded tests for parser/configure/idempotency/basic CLI behavior and rollback/backup flow
- updated docs for local setup and recovery/rollback

## Out of Scope
- `.deb` packaging implementation
- release automation
- APT publishing
- CI/release checklist hardening beyond what Phase 2 needs
- GitHub auth, secrets, or signing materials

## Brownfield Inputs Used Selectively
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/install_packages.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/install_ohmyzsh.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/install_plugins.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/configure_zshrc.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/apply_user_request.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/verify.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/doctor.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/backups.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/tasks/test.sh`

## Deliverables
1. Phase 2 planning artifacts and updated implementation ledger
2. Active CLI/task implementations replacing Phase 1 placeholders
3. Profile files and config defaults for safe, explicit customization
4. Safer configure flow with idempotent zsh bootstrap management
5. Expanded local test harness proving parser/configure/verify/rollback behavior without touching the real environment
6. Recovery and rollback documentation

## Acceptance Criteria
- current work is on `feat/phase2-cli-hardening`
- Phase 2 planning artifacts exist in `.omx/plans/`
- `./dev-env` core commands perform real work instead of placeholder output
- `bootstrap --dry-run --no-packages` succeeds as a non-destructive smoke path
- `configure` no longer injects legacy `clear`, `python3 ~/.bg.py`, or `ls` by default
- named profiles can drive plugin/theme defaults without surprising shell startup behavior
- local tests pass, including parser/configure/idempotency/basic CLI behavior and backup/rollback flows
- no Phase 3 packaging or release work is started

## Risks and Mitigations
- **Risk:** accidental machine mutation during verification.
  - **Mitigation:** use temp HOME/path shims in tests and rely on `--dry-run` for smoke paths.
- **Risk:** carrying over unsafe brownfield defaults.
  - **Mitigation:** omit resource auto-init and make profile customization explicit.
- **Risk:** brittle shell tests.
  - **Mitigation:** prefer temp directories, fake executables, and idempotent checks.
