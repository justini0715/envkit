# Local Setup Runbook

## Purpose
Describe the supported standalone `dev-env` workflow through Phase 4.

## Preconditions
- work from `/home/iostream/autopilot-test`
- stay on `feat/phase4-hardening`
- treat `/home/iostream/Desktop/dev-env` as brownfield-reference input only

## Recommended Local Commands
```bash
make lint
make format-check
./dev-env bootstrap --dry-run --no-packages --profile minimal
./dev-env test
make package-deb VERSION=0.3.0-test
./tests/phase3-packaging-smoke.sh
make verify
```

## Local Install Path
```bash
./install.sh --prefix "$HOME/.local"
```

## Personal Opt-In Profile

To restore your own interactive startup commands without making them global defaults:

```bash
./dev-env configure --profile personal
```

This uses `config/user/personal-request.txt` and writes the commands into the managed user drop-in instead of forcing them into the default bootstrap path.

## Release Readiness Path
- use `make release-preflight` for the full local gate
- use `docs/checklists/release-checklist.md` before tagging
- use `docs/release-notes-template.md` to draft release notes
