Use ./project_manual.md as the execution source of truth.
Inspect /home/iostream/Desktop/dev-env only as a brownfield reference.

Continue this project and complete only the current phase defined in docs/architecture/implementation-plan.md.
Do not skip to later phases.

Requirements:
- branch-based workflow only
- no scope reduction
- verify before claiming completion
- update docs as implementation changes
- preserve the standalone product direction

Stop only for:
- credentials, GitHub auth, GPG secrets, external publish authorization
- permission escalation that cannot proceed automatically
- destructive actions not already approved

Completion means:
- current phase deliverables are done
- tests/build/smoke for that phase pass
- final evidence is reported clearly
