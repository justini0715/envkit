# dev-env Autonomous Rebuild Manual for Codex / OMX

> 목적: 이 문서는 `/home/iostream/Desktop/dev-env`의 기존 구현을 참고해,  
> `/home/iostream/autopilot-test`에서 **독립된 제품형 CLI 프로젝트**로 `dev-env`를 처음부터 끝까지 재구성하기 위한 실행 매뉴얼이다.  
> 사람용 브레인스토밍 문서가 아니라 **Codex/OMX 실행 지침**으로 사용한다.

---

## 0. Source of Truth and Scope

### Primary source of truth
- This file

### Brownfield reference source
- `/home/iostream/Desktop/dev-env`

### Target execution repository
- `/home/iostream/autopilot-test`

### Product goal
Build a polished, releaseable CLI product named `dev-env` that can:
- bootstrap a Debian/Ubuntu development shell environment
- configure zsh / oh-my-zsh / plugins / theme / user request drop-ins
- verify and diagnose the environment
- backup and rollback managed changes
- package itself for `.deb` distribution
- support GitHub Release quality and optional APT repository publishing

### Non-goals for the first complete autonomous pass
- supporting macOS or Homebrew
- supporting non-Debian Linux package managers
- supporting arbitrary plugin repositories without guardrails
- remote infrastructure beyond GitHub Releases / optional GitHub Pages APT flow
- a GUI or web UI

---

## 1. High-Level Product Direction

This must be rebuilt as a **standalone product repo**, not as a generic `archive` repository with tools nested under `tools/dev-env`.

The resulting repository should feel like a real CLI product:
- clear project identity
- clean root structure
- usable README
- deterministic setup flow
- explicit verification
- packaging and release flow
- safe defaults

Do not merely copy the old repo structure.  
Carry over good implementation ideas, but simplify and productize.

---

## 2. Brownfield Findings to Respect

The old repo already has useful strengths that should be preserved where appropriate:

1. Command surface already exists:
   - `bootstrap`
   - `packages`
   - `ohmyzsh`
   - `plugins`
   - `configure`
   - `apply-user`
   - `verify`
   - `doctor`
   - `test`
   - `backups-list`
   - `rollback`
   - `clean-backups`
   - `chsh`

2. Existing quality strengths:
   - configure flow has idempotency coverage
   - backup behavior exists
   - request parser exists
   - `.deb` packaging exists
   - GitHub Pages APT publishing workflow exists

3. Existing local evidence:
   - `make -C /home/iostream/Desktop/dev-env/tools/dev-env test` passed during review

---

## 3. Brownfield Problems That Must Be Fixed

The rebuild must explicitly solve these issues.

### 3.1 Product identity / repo structure issues
- The current root README identifies the repo as `archive`, not the product.
- The product is nested under `tools/dev-env` instead of being the repo’s clear primary identity.

### 3.2 Packaging quality issues
- The current Debian package control file only depends on `bash`, even though the runtime flow expects more tools.
- Packaging quality must be hardened so the package is honest about dependencies and operator expectations.

### 3.3 Safety / operator experience issues
- Default resource init currently implies startup behavior like `clear`, `python3 ~/.bg.py`, and `ls`.
- These behaviors are too opinionated to be silently forced as the default experience.
- Keep them only if they become explicit profile or opt-in behavior.

### 3.4 Security / secret hygiene issues
- Existing documentation writes generated GPG material under a repo-local `dist/gpg/` path.
- The rebuilt version must avoid encouraging long-lived private keys inside the repo tree.
- Use a safer default path outside tracked project contents, or clearly separate sensitive local state.

### 3.5 Verification gaps
- Current tests are good for syntax and configuration idempotency, but they are not enough for full product confidence.
- Add broader CLI smoke coverage, packaging smoke coverage, and documentation-driven verification.

---

## 4. Branch Policy

- Do not work directly on `main` or `master`.
- Use dedicated branches per phase.
- Recommended branch names:
  - `feat/phase1-product-foundation`
  - `feat/phase2-cli-hardening`
  - `feat/phase3-packaging-release`
  - `feat/phase4-hardening`

If the user instructs branch-based workflow, it is mandatory.

---

## 5. Required Final Product Shape

The rebuilt repository should look roughly like this:

```text
dev-env/
  README.md
  LICENSE
  Makefile
  AGENTS.md
  project_manual.md
  config/
    zsh/
    user/
    profiles/
  docs/
    architecture/
    adr/
    runbooks/
    checklists/
  packaging/
    build-deb.sh
    build-apt-repo.sh
    generate-gpg-key.sh
    github-secrets-apply.sh
  resources/
  scripts/
    dev-env.sh
    main.sh
    lib.sh
    tasks/
  install.sh
  tests/
```

If another clean structure is better, it may be used, but it must remain clearly product-centric.

---

## 6. Required Features

### 6.1 Core CLI features
- `bootstrap`
- `packages`
- `ohmyzsh`
- `plugins`
- `configure`
- `apply-user`
- `verify`
- `doctor`
- `test`
- `backups-list`
- `rollback`
- `clean-backups`
- `chsh`

### 6.2 New or improved features required in the rebuild
- `--dry-run` support where practical
- safer profile-based customization
- explicit “minimal” vs “full” or named profile support
- improved doctor output
- clearer install path for local and package-based usage
- clearer recovery / rollback documentation

### 6.3 Strongly recommended additions
- `install.sh` bootstrap entrypoint
- release checklist
- shellcheck / shfmt / CI verification
- packaging smoke test
- example profile definitions such as:
  - `minimal`
  - `cpp-42`
  - `general-dev`

---

## 7. Explicit Keep / Drop Rules

### Keep
- shell-based implementation approach unless there is a compelling reason to change it
- request parsing idea
- backup and rollback support
- `.deb` packaging support
- GitHub Pages APT publishing path as an optional distribution channel
- idempotent configuration behavior

### Drop or change
- root `archive` identity
- nesting the real product under `tools/dev-env`
- forcing visual/banner startup behavior by default
- unsafe-seeming secret generation paths inside normal repo output directories
- incomplete package dependency metadata

---

## 8. Official Phase Order

Do not skip phase order.  
Do not claim completion by file creation alone.  
Each phase must pass its verification gate before moving on.

### Phase 1 — Product Foundation
Goal:
- turn the project into a clean standalone product repository

Must include:
- product-centric repo structure
- `README.md`
- `AGENTS.md`
- `project_manual.md`
- `docs/architecture/implementation-plan.md`
- root `Makefile`
- root CLI entrypoint strategy
- `.gitignore`
- clear branch policy in docs
- copied/adapted core scripts from the reference repo only where justified

Done when:
- repository structure is coherent
- documentation explains local usage
- `make help` or equivalent works
- basic CLI command entrypoints resolve

### Phase 2 — CLI Hardening
Goal:
- make local bootstrap/configure/verify/doctor functionality reliable

Must include:
- packages / ohmyzsh / plugins / configure / apply-user / verify / doctor / rollback flows
- safer defaults for shell init behavior
- profile support or equivalent configuration clarity
- expanded tests for parser/configure/idempotency/basic CLI behavior

Done when:
- local tests pass
- local CLI smoke checks pass
- dangerous or surprising defaults are removed or made opt-in

### Phase 3 — Packaging and Release
Goal:
- make the tool releaseable as a real distributable artifact

Must include:
- `.deb` packaging
- truthful dependency handling
- packaging smoke verification
- `install.sh`
- GitHub Release readiness
- optional GitHub Pages APT repo flow
- release docs/checklists

Done when:
- package build succeeds
- install path is documented and coherent
- release artifacts and release procedure are documented

### Phase 4 — Hardening and Polish
Goal:
- make the project maintainable and worthy of public release

Must include:
- CI quality checks
- shellcheck / formatting / test gates
- better docs and runbooks
- profile examples
- operator troubleshooting guidance
- final release notes scaffold

Done when:
- core verification passes reproducibly
- docs are coherent
- project is ready for a tagged GitHub release

---

## 9. Verification Policy

### Minimum verification order
1. syntax checks
2. unit or script-level tests
3. CLI smoke tests
4. package build
5. package smoke verification
6. documentation sanity check

### Required commands by the end of the project
At minimum, the rebuild should provide and validate equivalents of:

- `make help`
- `make test`
- `make verify`
- `dev-env help`
- `dev-env doctor`
- `dev-env bootstrap --no-packages` or equivalent non-destructive smoke path
- package build command

### Final release readiness evidence must include
- commands run
- pass/fail results
- built artifact paths
- known limitations

Do not claim “complete” without fresh verification.

---

## 10. Required Documentation

The rebuild must end with these docs at minimum:

- `README.md`
- `docs/architecture/implementation-plan.md`
- `docs/adr/0001-product-repo-structure.md`
- `docs/adr/0002-safe-shell-init-defaults.md`
- `docs/adr/0003-packaging-and-release-strategy.md`
- `docs/runbooks/local-setup.md`
- `docs/runbooks/recovery-and-rollback.md`
- `docs/checklists/release-checklist.md`

---

## 11. Stop Conditions

Stop and report only when one of these is required:

1. user credentials or tokens
2. GitHub login / secret setup / GPG passphrase entry
3. external network publishing that needs user authorization
4. package installation or system modification that requires approval not already available
5. destructive operations not explicitly approved

If blocked, report:
- what was completed
- what is blocked
- exact user action required

---

## 12. Reporting Format

Use this for progress:

### Progress Update
- Current phase:
- Branch:
- Completed:
- In progress:
- Blocked:
- Next:

Use this for final phase completion:

### Phase Completion Report
- Phase:
- Branch:
- Deliverables:
- Verification commands:
- Verification results:
- Risks / limitations:
- User action required:
- Recommended next step:

---

## 13. Implementation Notes for Brownfield Migration

When examining `/home/iostream/Desktop/dev-env`, treat it as a **reference implementation**, not something to mirror blindly.

### Inspect first
- existing CLI command structure
- tests
- packaging
- docs
- workflows

### Preserve selectively
- preserve good script logic
- preserve test ideas
- preserve docs topics
- preserve packaging pipeline ideas

### Do not preserve blindly
- repo layout
- naming that obscures the product
- surprising shell startup effects
- insecure local secret handling patterns

---

## 14. Recommended Execution Strategy

### If using Autopilot
Autopilot should own:
- expansion
- planning
- broad execution orchestration
- QA
- final validation

### If using Ralph
Use Ralph for:
- one current phase at a time
- blocked-phase resumption
- hardening after autopilot planning
- “finish this phase completely” execution

### Preferred combined workflow
1. Autopilot for full product spec + implementation plan + broad build
2. Ralph for the active phase if execution becomes unreliable or needs stricter completion gating

---

## 15. Exact Prompt for Autopilot

Use this as the initial prompt in the target repo:

```text
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
```

---

## 16. Exact Prompt for Ralph

Use this when continuing or forcing strict completion on a specific phase:

```text
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
```

---

## 17. Start Procedure

When starting in `/home/iostream/autopilot-test`:

1. ensure this file is present as `project_manual.md`
2. create a short `AGENTS.md` that points to `project_manual.md`
3. confirm current branch is not `main`
4. create/update `docs/architecture/implementation-plan.md`
5. run the autopilot prompt
6. if execution drifts, switch to Ralph for the active phase

---

## 18. Completion Rule

Do not stop at “working scripts exist”.
The project is only complete when it is:
- understandable
- verifiable
- safe enough to use on a real VM
- packaged
- documented
- ready for a tagged public release

