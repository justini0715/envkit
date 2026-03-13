# Test Spec — Phase 4 Hardening and Polish

## Goal
Prove the project is release-ready with reproducible lint/test/package verification and coherent docs.

## Test Strategy
- syntax: `bash -n` on repo shell files
- lint: `make lint`
- formatting: `make format-check`
- CLI/test/package smoke: `./dev-env test`, `./tests/phase3-packaging-smoke.sh`, `make verify`
- docs sanity: ensure troubleshooting and release-notes files exist and are referenced
- CI config sanity: ensure `.github/workflows/ci.yml` exists and references lint/test/package smoke

## Recommended Command Sequence
```bash
bash -n dev-env scripts/*.sh scripts/tasks/*.sh packaging/*.sh install.sh tests/*.sh tests/smoke/*.sh
make lint
make format-check
./dev-env test
./tests/phase3-packaging-smoke.sh
make verify
```

## Expected Results
- all commands exit successfully
- shellcheck and shfmt checks pass
- package smoke still passes
- final docs exist and the repo is ready for a tagged GitHub release
