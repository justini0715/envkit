# Test Spec — Phase 2 CLI Hardening

## Goal
Prove the rebuilt CLI core works for local/bootstrap/configure/verify/rollback behavior without modifying the developer's real machine.

## Test Strategy

### 1. Syntax and structure checks
- `bash -n` on all shell entrypoints and tests
- ensure Phase 2 planning/docs/config/profile files exist

### 2. CLI smoke checks
- `make help`
- `./envkit help`
- `./envkit bootstrap --dry-run --no-packages --profile minimal`
- `./envkit packages --dry-run`
- `./envkit ohmyzsh --dry-run`
- `./envkit plugins --dry-run --profile general-dev`
- `./envkit configure --dry-run --profile minimal`
- `./envkit chsh --dry-run`

### 3. Temp-environment integration checks
Inside a temp HOME/PATH with command shims:
- `bootstrap --no-packages` creates a safe zsh bootstrap without legacy init defaults
- `apply-user` parses request text into plugin/theme/user drop-in outputs
- repeated `configure` runs are idempotent
- `verify` passes against the temp environment
- `doctor` passes and reports safe startup behavior
- `backups list`, `rollback`, and `clean` behave correctly

### 4. Make target verification
- `make test`
- `make verify`

## Recommended Command Sequence
```bash
bash -n envkit scripts/*.sh scripts/tasks/*.sh tests/*.sh tests/smoke/*.sh
./envkit bootstrap --dry-run --no-packages --profile minimal
./envkit packages --dry-run
./envkit ohmyzsh --dry-run
./envkit plugins --dry-run --profile general-dev
./envkit configure --dry-run --profile minimal
./envkit chsh --dry-run
./envkit test
make help
make test
make verify
```

## Expected Results
- all commands exit successfully
- dry-run commands print planned actions without mutating the real machine
- temp-environment integration tests prove real task behavior
- no default `clear`, `python3 ~/.bg.py`, or `ls` are injected into managed zsh config
- rollback/backup flows are validated locally
