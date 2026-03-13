# PRD — Phase 1 Product Foundation

## Phase
- Phase 1 — Product Foundation
- Branch: `feat/phase1-product-foundation`

## Objective
Turn the repository into a clean, product-centric `dev-env` CLI workspace that can support later implementation phases without inheriting the nested `archive/tools/dev-env` structure.

## Problem Statement
The rebuild needs a stable foundation before any environment-mutating shell logic is carried forward. Today the repo has execution guidance, but it still needs the phase-specific planning artifacts, scaffolded product structure, and a reliable local command surface for autonomous work.

## Users
- Maintainers rebuilding `dev-env` phase-by-phase
- Codex / OMX agents that need deterministic repo structure and command routing
- Future operators who need clear docs and local verification entrypoints

## In Scope
- product-centric repository layout at the repo root
- root `Makefile` with phase-appropriate help and verification targets
- local CLI entrypoint strategy (`./dev-env`, `scripts/dev-env.sh`, `scripts/main.sh`, shared lib)
- creation of foundational directories (`config`, `docs`, `scripts`, `tests`, `packaging`, `resources`)
- phase-specific docs and runbooks for local usage
- smoke-safe command routing where later-phase commands resolve explicitly without mutating the system yet

## Out of Scope
- real package installation, Oh My Zsh installation, plugin installation, or shell mutation
- rollback implementation details
- `.deb` packaging logic
- GitHub release or APT publishing
- CI hardening, shellcheck gates, or profile implementations beyond placeholders

## Brownfield Inputs Used Selectively
- `/home/iostream/Desktop/dev-env/tools/dev-env/README.md` — command surface and operator-facing framing
- `/home/iostream/Desktop/dev-env/tools/dev-env/Makefile` — target naming and help layout inspiration
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/main.sh` — task-router shape
- `/home/iostream/Desktop/dev-env/tools/dev-env/scripts/dev-env.sh` — CLI command mapping shape

## Deliverables
1. Missing planning artifacts for Phase 1 in `.omx/plans/`
2. Updated `docs/architecture/implementation-plan.md` reflecting live Phase 1 execution
3. Product README with current-phase usage guidance
4. Root `Makefile` with `help`, `doctor`, `test`, and `verify`
5. Root CLI shim plus script router scaffold
6. Foundational config/docs/tests directory structure with phase-safe placeholders
7. Local smoke verification proving the Phase 1 scaffold resolves cleanly on the current branch

## Acceptance Criteria
- Current branch remains non-`main` / non-`master`
- `.omx/plans/prd-phase1-product-foundation.md` exists
- `.omx/plans/test-spec-phase1-product-foundation.md` exists
- `make help` succeeds
- `./dev-env help` succeeds
- `./dev-env doctor` succeeds and reports branch/doc/artifact status
- `./dev-env test` and `./dev-env verify` succeed locally
- Later-phase commands such as `packages`, `ohmyzsh`, `plugins`, `configure`, `apply-user`, `backups-*`, and `chsh` resolve with explicit deferred messaging instead of missing-file errors
- No later-phase implementation is started

## Risks and Mitigations
- **Risk:** accidentally drifting into Phase 2 implementation.
  - **Mitigation:** keep active behavior limited to docs, routing, smoke tests, and explicit deferred placeholders.
- **Risk:** mirroring the old nested repo layout too literally.
  - **Mitigation:** use only the command naming and routing ideas, not the directory nesting or opinionated resources.
- **Risk:** unverified scaffolding.
  - **Mitigation:** add shell syntax checks and smoke tests as part of `test` and `verify`.

## Release of This Phase
Phase 1 is complete when the repo identity, command routing scaffold, and local verification workflow are all present and demonstrably working without performing real system mutation.
