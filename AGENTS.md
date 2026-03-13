# AGENTS.md

Follow `project_manual.md` as the project execution source of truth.

Additional rules:
- Work phase-by-phase only.
- Do not work directly on main/master.
- Use a dedicated branch per phase.
- Treat `/home/iostream/Desktop/dev-env` as a brownfield reference, not as a copy target.
- Do not skip local verification.
- Stop and report if user action, credentials, external auth, or permission escalation is required.
- Update `docs/architecture/implementation-plan.md` before and during execution.
- Do not start the next phase unless explicitly instructed.
