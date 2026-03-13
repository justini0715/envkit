# ADR 0002: Safe shell-init defaults

- Status: Accepted
- Date: 2026-03-13
- Phase: Phase 2 — CLI Hardening

## Context
The brownfield reference shipped startup resource behavior that effectively ran `clear`, `python3 ~/.bg.py`, and `ls` by default. That is too opinionated and surprising for a product-quality CLI.

## Decision
Phase 2 removes those behaviors from the default configure path.

Instead:
- zsh bootstrap management only ensures the managed dev-env block and drop-in loading exist
- profiles control explicit plugin/theme defaults
- user-request `init:` commands remain opt-in and are written only when explicitly requested
- resources remain reserved for later explicit/opt-in behavior, not silent startup mutation

## Consequences
### Positive
- safer operator experience
- clearer separation between product defaults and user customization
- easier local verification because startup side effects are not hidden

### Trade-off
- users who liked the old startup effects must opt in explicitly rather than receiving them by default
