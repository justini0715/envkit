# ADR 0001: Product-first repository structure

- Status: Accepted
- Date: 2026-03-13
- Phase: Phase 1 — Product Foundation

## Context
The brownfield reference lives inside `/home/iostream/Desktop/dev-env/tools/dev-env` under an `archive` repository. The rebuild needs to present `dev-env` as the repository's primary product identity while still reusing good ideas from the old command surface and routing model.

## Decision
Use a product-first root structure in `/home/iostream/autopilot-test`:
- root README and Makefile describe `dev-env` directly
- root CLI shim (`./dev-env`) routes into `scripts/dev-env.sh`
- `scripts/main.sh` dispatches task scripts under `scripts/tasks/`
- `config/`, `docs/`, `tests/`, `packaging/`, and `resources/` are top-level product areas
- later-phase features remain deferred until their official phase begins

## Consequences
### Positive
- clearer product identity
- easier local usage and verification
- smoother progression into later CLI, packaging, and release phases
- avoids inheriting the old nested repo layout

### Negative
- some command surfaces are placeholders during Phase 1
- additional documentation is needed to explain what is deferred vs active

## Notes
This decision preserves the recognizable command vocabulary from the brownfield repo while intentionally deferring real environment mutation to Phase 2 and packaging/release work to Phase 3.
