# Test Spec — Phase 1 Product Foundation

## Goal
Verify the Phase 1 foundation without performing the real environment bootstrap or packaging work that belongs to later phases.

## Verification Principles
- Prefer local, non-destructive checks.
- Treat shell syntax checks and CLI smoke checks as the proof for this phase.
- Ensure later-phase commands resolve explicitly, even if they are intentionally deferred.

## Test Matrix

### 1. Repository foundation checks
Validate that the required Phase 1 control files and directories exist.
- `README.md`
- `AGENTS.md`
- `project_manual.md`
- `docs/architecture/implementation-plan.md`
- `Makefile`
- `dev-env`
- `scripts/dev-env.sh`
- `scripts/main.sh`
- `scripts/lib.sh`
- `tests/phase1_smoke.sh`
- `.omx/plans/prd-phase1-product-foundation.md`
- `.omx/plans/test-spec-phase1-product-foundation.md`

### 2. Branch policy check
Confirm the working branch is not `main` or `master`.

### 3. Shell syntax checks
Run `bash -n` across the new shell entrypoints and tests.

### 4. CLI smoke routing
Validate:
- `./dev-env help`
- `./dev-env doctor`
- `./scripts/main.sh doctor`
- `./dev-env packages` returns a deferred Phase 2 message
- `./dev-env rollback --backup-file /tmp/example.bak` returns a deferred Phase 2 message

### 5. Make target smoke
Validate:
- `make help`
- `make test`
- `make verify`

## Recommended Command Sequence
```bash
bash -n dev-env scripts/*.sh scripts/tasks/*.sh tests/*.sh
make help
./dev-env help
./dev-env doctor
./dev-env packages
./dev-env rollback --backup-file /tmp/example.bak
./dev-env test
./dev-env verify
make test
make verify
```

## Expected Results
- All commands exit successfully.
- Help output clearly labels the repo as Phase 1 Product Foundation.
- `doctor` reports the current branch, planning artifacts, and foundation files.
- Deferred commands explain that the command surface exists but implementation is scheduled for Phase 2.
- `test` and `verify` complete without mutating the user environment.

## Explicit Non-Goals for This Test Spec
- installing packages
- modifying `~/.zshrc`
- installing Oh My Zsh or plugins
- creating `.deb` artifacts
- publishing anything to GitHub or APT
