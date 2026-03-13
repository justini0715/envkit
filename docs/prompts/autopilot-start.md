Use ./project_manual.md as the execution source of truth.
Also inspect /home/iostream/Desktop/dev-env as a brownfield reference implementation, but do not mirror it blindly.

Build dev-env as a standalone product-quality CLI repository from start to finish.

Goals:
- create a polished standalone repo for dev-env
- preserve useful command flows from the old repo
- fix product identity, packaging honesty, safety defaults, verification depth, and release quality
- end with a releaseable CLI project with docs, tests, packaging, and GitHub Release readiness

Rules:
- do not work directly on main/master
- use dedicated branches per phase
- follow the official phase order in project_manual.md
- verify each phase before moving on
- do not ask unnecessary questions
- choose reasonable defaults and document them

Hard requirements:
- standalone product repo, not archive-style nesting
- strong README and implementation plan
- core CLI commands implemented and documented
- safer shell-init defaults
- stronger test and smoke coverage
- .deb packaging and release workflow
- release docs and checklists

Stop only when:
- credentials, GPG passphrase entry, GitHub auth, or external publish authorization is required
- permission escalation is required and cannot proceed automatically
- destructive actions would be required

Completion means:
- local tests pass
- CLI smoke checks pass
- package build passes
- docs are updated
- final report includes commands run and evidence
