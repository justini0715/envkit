Use `./project_manual.md` as the execution source of truth and `./AGENTS.md` as the repo-local rule file.
Also inspect `/home/iostream/Desktop/dev-env` as a brownfield reference implementation, but do not mirror it blindly.

This repository already contains starter execution documents and Phase 1 bootstrap artifacts. Refine and use them instead of discarding them unless there is a strong reason.

Project objective:
Build `dev-env` as a standalone, product-quality Debian/Ubuntu zsh bootstrap CLI that is suitable for a public GitHub release.

Required outcomes:
- standalone product repo identity
- clear root structure
- strong README and implementation plan
- shell-based CLI with documented commands
- safe zsh / oh-my-zsh / plugin / theme / request configuration flows
- verify / doctor / backup / rollback flows
- stronger smoke tests and release-quality verification
- `.deb` packaging
- release documentation and GitHub Release readiness
- optional GitHub Pages APT publishing flow as a later phase concern

Execution rules:
- do not work directly on `main` or `master`
- start from the current phase branch if already present
- use dedicated branches per phase
- follow the official phase order in `project_manual.md`
- verify each phase before moving to the next
- do not ask unnecessary questions
- choose reasonable defaults and document them
- preserve useful ideas from the brownfield repo, but simplify and productize

Important constraints:
- remove archive-style / nested-tool repo identity
- do not ship personal shell startup behavior as the default product experience
- do not normalize unsafe local secret handling patterns
- keep Debian/Ubuntu as the supported v1 target
- prefer a narrow, reliable product over a broad but fuzzy one

Stop only when:
- credentials, GitHub auth, GPG passphrase entry, or external publish authorization is required
- permission escalation is required and cannot proceed automatically
- destructive actions would be required

Completion standard:
- all planned phases are completed in order
- tests pass with fresh evidence
- CLI smoke checks pass with fresh evidence
- package build passes with fresh evidence
- docs are updated
- final report includes commands run, verification results, remaining limitations, and any user action required
