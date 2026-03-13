# envkit

A standalone Debian/Ubuntu development-environment CLI rebuild.

This repository is rebuilt from `/home/iostream/Desktop/dev-env` as a product-first repo rather than a nested `archive/tools/dev-env` project.

## Current Phase

**Phase 4 — Hardening and Polish** is the active phase on branch `feat/phase4-hardening`.

Phase 4 adds:
- CI verification for lint/format/test/package smoke
- local shellcheck/shfmt gates
- troubleshooting guidance and release-notes scaffold
- final doc/release-readiness polish

## Core Verification

```bash
make lint
make format-check
./envkit test
./tests/phase3-packaging-smoke.sh
make verify
```

## Install / Package Paths

### Local prefix install
```bash
./install.sh --prefix "$HOME/.local"
```

### Debian package build
```bash
make package-deb VERSION=0.3.0-test
```

### Local package smoke
```bash
./tests/phase3-packaging-smoke.sh
```

## Packaging Notes

- package metadata declares runtime expectations more honestly than the brownfield baseline
- generated GPG material defaults to `${XDG_STATE_HOME:-$HOME/.local/state}/envkit/gpg`
- package smoke uses unpacked artifacts and temp prefixes instead of root installs
- GitHub publish/auth steps remain documented but are not required for local verification

## Profiles

Profiles live under `config/profiles/`:
- `minimal`
- `general-dev`
- `cpp-42`
- `personal`

## Repository Shape

```text
envkit/
  AGENTS.md
  project_manual.md
  README.md
  Makefile
  install.sh
  config/
  docs/
  packaging/
  resources/
  scripts/
  tests/
  .github/workflows/
```

## Local Usage Notes

- `project_manual.md` is the execution source of truth.
- `AGENTS.md` defines repo-local execution rules.
- `docs/architecture/implementation-plan.md` is the active phase ledger.
- Follow a branch-per-phase workflow and work only on the current non-main phase branch.

For final release-readiness details, see:
- `docs/runbooks/troubleshooting.md`
- `docs/release-notes-template.md`
- `docs/checklists/release-checklist.md`
