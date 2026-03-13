# envkit

A standalone Debian/Ubuntu development-environment CLI rebuild.

This repository is rebuilt from `/home/iostream/Desktop/dev-env` as a product-first repo rather than a nested `archive/tools/dev-env` project.

## Current Release

The latest released product is **envkit**.

What it includes:
- envkit CLI for bootstrap/configure/verify/doctor/rollback flows
- signed APT repository on GitHub Pages
- Debian package builds and local install path
- CI verification for lint/format/test/package smoke
- troubleshooting guidance and release-notes scaffold

## Core Verification

```bash
make lint
make format-check
./envkit test
./tests/phase3-packaging-smoke.sh
make verify
```

## Install / Package Paths

### Signed APT install
```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://justini0715.github.io/envkit/public.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/envkit-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/envkit-archive-keyring.gpg] https://justini0715.github.io/envkit stable main" \
  | sudo tee /etc/apt/sources.list.d/envkit.list >/dev/null

sudo apt update
sudo apt install -y envkit
```

### After install
```bash
envkit help
envkit bootstrap --no-packages --profile minimal
envkit doctor --profile minimal
```

If you want your personal interactive startup commands back as an explicit opt-in:

```bash
envkit configure --profile personal
```

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

For release-readiness and operations details, see:
- `docs/runbooks/troubleshooting.md`
- `docs/release-notes-template.md`
- `docs/checklists/release-checklist.md`
- `docs/runbooks/developer-guide.md`
