# ADR 0003: Packaging and release strategy

- Status: Accepted
- Date: 2026-03-13
- Phase: Phase 3 — Packaging and Release

## Context
The rebuilt repository now has a standalone CLI core, but it is not yet releaseable without package artifacts, a local install path, and coherent release documentation.

## Decision
Phase 3 uses:
- `.deb` packaging rooted at the standalone repo layout
- `/usr/lib/envkit` + `/usr/bin/envkit` wrapper packaging layout
- local `install.sh --prefix <path>` for non-package installs
- unsigned/local APT repo smoke verification by default
- GPG material generated under local state outside tracked repo contents
- GitHub Pages APT publication as an optional documented workflow, not a required local verification step

## Consequences
### Positive
- release artifacts can be built and inspected locally
- packaging smoke avoids root/system mutation
- secrets and private keys are pushed out of tracked repo output directories
- release docs match the standalone product identity

### Trade-off
- live publish/auth remains a documented manual step until later phases/hardening
