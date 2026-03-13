# PRD — Phase 3 Packaging and Release

## Phase
- Phase 3 — Packaging and Release
- Branch: `feat/phase3-packaging-release`

## Objective
Make `dev-env` releaseable as a distributable artifact by adding Debian packaging, package smoke verification, a coherent local install path, and release/APT publication documentation/workflows without performing live publishing.

## In Scope
- `.deb` packaging scripts adapted to the standalone repo layout
- truthful dependency handling in package metadata
- package smoke verification that does not require system install
- `install.sh` for local installation into a chosen prefix
- GitHub Release / GitHub Pages APT repo readiness artifacts and docs
- release checklist and packaging strategy ADR
- safer default location for generated GPG material outside tracked repo contents

## Out of Scope
- actual GitHub login / secrets application
- live package publishing
- signed release execution requiring user credentials or passphrase entry
- CI hardening or release notes polish beyond Phase 3 needs

## Brownfield Inputs Used Selectively
- `/home/iostream/Desktop/dev-env/tools/dev-env/packaging/build-deb.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/packaging/build-apt-repo.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/packaging/generate-gpg-key.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/packaging/github-secrets-apply.sh`
- `/home/iostream/Desktop/dev-env/tools/dev-env/docs/github-apt-repo.md`
- `/home/iostream/Desktop/dev-env/tools/dev-env/docs/checklists/github-apt-release-checklist.md`

## Deliverables
1. Phase 3 planning artifacts and updated implementation ledger
2. `packaging/` scripts for `.deb`, APT repo, GPG material, and GitHub secrets application
3. `install.sh` for local product installation
4. package smoke test coverage and Makefile targets
5. Phase 3 docs: packaging strategy ADR, release checklist, install/release guidance
6. optional GitHub Pages APT workflow scaffold without requiring live auth during verification

## Acceptance Criteria
- current work is on `feat/phase3-packaging-release`
- Phase 3 planning artifacts exist in `.omx/plans/`
- `make package-deb` succeeds locally
- package smoke verification passes against the built artifact
- install path is documented and coherent for local and package-based usage
- release docs/checklist exist and match the standalone repo layout
- generated GPG material defaults outside tracked repo contents
- no live publish/auth steps are required to verify completion
