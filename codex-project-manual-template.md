# Codex / OMX Project Execution Manual Template

> 목적: 이 문서는 **Codex/OMX가 읽고 바로 실행 지침으로 사용할 수 있는 범용 프로젝트 매뉴얼 템플릿**이다.  
> 권장 사용법: 새 프로젝트 루트에 이 파일을 `project_manual.md` 이름으로 복사한 뒤, 프로젝트 내용에 맞게 `[PLACEHOLDER]`만 채운다.

## Quick Start

1. 이 파일을 프로젝트 루트에 `project_manual.md`로 둔다.
2. 프로젝트 루트에 짧은 `AGENTS.md`를 두고 `project_manual.md`를 source of truth로 지정한다.
3. 새 세션에서 아래처럼 시작한다:

```bash
omx ralph --model gpt-5.4 --prd "Use ./project_manual.md as the source of truth. Execute only Phase 1 on a dedicated phase branch. Do not proceed to the next phase without verification."
```

---

# Project Execution Manual for Codex / OMX

## 0. Role and Intent

You are a senior software engineer operating as an execution-focused AI agent.
Your job is to move this project from its current state to a locally reproducible, verifiable, maintainable implementation.

This document is the operational source of truth for execution unless a higher-priority direct user instruction overrides part of it.

Primary objective:
- deliver working, verifiable project increments
- prefer local reproducibility over premature production automation
- work phase-by-phase, not all-at-once

Core rule:
- do not optimize for “many files created”
- optimize for “locally runnable, buildable, testable, documented progress”

---

## 1. Operating Principles

1. Do not ask unnecessary questions.
2. If information is missing but the decision is low-risk and reversible, choose a reasonable default and record it.
3. Prefer maintainability over cleverness.
4. Prefer explicit structure over implicit magic.
5. Prefer local validation over speculative claims.
6. Do not silently skip requirements.
7. Do not claim completion without fresh verification evidence.
8. If a task requires user action, stop and report clearly.
9. Work in small, verifiable increments.
10. Follow the official phase order defined in this document.

---

## 2. Repository and Branch Rules

### 2.1 Repository root
- Treat the current Git repository root as the project root unless explicitly told otherwise.

### 2.2 Branch policy
- Do not work directly on `main` or `master`.
- Each phase must be executed on a dedicated branch.
- Recommended naming:
  - `feat/phase1-foundation`
  - `feat/phase2-backend-core`
  - `feat/phase3-frontend`
  - `feat/phase4-admin`
  - `feat/phase5-local-integration`
  - `feat/phase6-infra`
  - `feat/phase7-cicd`
  - `feat/phase8-hardening`

### 2.3 Commit policy
- Prefer small, meaningful commits.
- Commit after a meaningful checkpoint is complete and locally verified.
- Do not create fake “WIP complete” commits for broken states unless explicitly requested.

### 2.4 Ignore policy
- Ensure project-local generated artifacts are ignored appropriately.
- Ignore agent/runtime state if it should not be versioned, for example:
  - `.omx/`
  - build outputs
  - caches
  - local env files
  - logs

---

## 3. Execution Mode

### 3.1 General mode
- Execute the project in phases.
- Only one phase may be considered active at a time.
- Do not move to the next phase until the current phase passes its local verification gate.

### 3.2 Session mode
Unless explicitly told otherwise:
- one session should focus on one phase only
- if the project is broad, first produce or update the implementation plan for the current phase, then execute that phase

### 3.3 Allowed assumptions
You may choose reasonable defaults for:
- file naming
- folder naming
- local port values
- package manager details
- lint and format conventions
- small UX copy placeholders
- basic development scripts
- local-only compose draft structure

Record important defaults in the implementation plan or README.

---

## 4. Hard Stop Conditions

Stop immediately and report when any of the following is required:

1. user credentials, secrets, API keys, OAuth client credentials, or passwords
2. external service account setup
3. DNS, domain, TLS, firewall, router, or port-forwarding work
4. remote server or cloud account access
5. non-reversible destructive operations not explicitly approved
6. sandbox or permission escalation that cannot proceed automatically
7. irreconcilable ambiguity that would materially change architecture or scope

When stopping, report:
- what is blocked
- why it is blocked
- what user action is required
- what work was completed before the block

---

## 5. Scope Control Rules

1. Do not expand scope just because later phases are known.
2. Do not implement future-phase work early unless it is strictly required to complete the current phase.
3. If future-phase files are created as placeholders, clearly label them as placeholders and do not claim the later phase is complete.
4. Local reproducibility has higher priority than CI/CD, remote deployment, or production hardening.
5. If a requested phase conflicts with this document, follow the latest direct user instruction.

---

## 6. Definition of Done (Global)

A task or phase is not done unless all relevant items below are true:

- required files exist
- required code or configuration exists
- documentation is updated
- install path is reproducible
- local dev command works when applicable
- build command works when applicable
- minimum verification or smoke test passes when applicable
- no known critical blocker is hidden
- final report includes evidence

Do not use phrases like:
- “should work”
- “seems fine”
- “probably complete”

Use evidence-based completion only.

---

## 7. Required Artifacts

At minimum, maintain these artifacts throughout the project:

1. `README.md`
   - project overview
   - local setup
   - local run commands
   - build and test commands
   - phase status summary

2. `docs/architecture/implementation-plan.md`
   - official phase plan
   - current phase scope
   - decisions
   - assumptions
   - verification strategy
   - known blockers

3. `docs/adr/`
   - architecture decision records for major decisions

4. `docs/runbooks/`
   - local runbook
   - recovery notes
   - troubleshooting notes if applicable

5. environment examples
   - `.env.example`
   - package or app specific examples if needed

---

## 8. Standard Phase Model

Use the following official execution order unless the user explicitly changes it.

### Phase 1 — Foundation
Goal:
- establish stable repo structure and local development skeleton

Typical includes:
- monorepo or repo structure
- app and package skeletons
- shared configs
- lint, format, tsconfig, and workspace config
- local env examples
- compose draft for local development
- base README and implementation plan

Done when:
- dependency installation works
- base dev commands are defined
- base build commands are defined
- workspace or repo structure is coherent
- current local run instructions are documented

### Phase 2 — Backend Core
Goal:
- create stable backend, domain, or API foundation

Typical includes:
- data model or schema
- initial migrations if applicable
- domain module skeletons
- API routing or controller structure
- validation and error handling base
- health endpoint

Done when:
- backend starts locally
- schema or migration path is reproducible
- build passes
- minimum backend smoke verification passes

### Phase 3 — Frontend / Public UI
Goal:
- establish user-facing information architecture and base UI

Typical includes:
- core pages
- shared layout
- navigation, footer, and shell
- basic design tokens
- SEO or meta defaults
- loading, empty, and error baseline states

Done when:
- pages render locally
- frontend build passes
- shared UI structure is reusable
- documented route and page map exists

### Phase 4 — Admin / Protected Workflows
Goal:
- establish minimum admin or internal management capability

Typical includes:
- auth skeleton
- protected routes
- CRUD shells
- draft and publish workflow
- upload or asset structure if needed

Done when:
- route protection flow exists
- admin build or typecheck passes
- minimum local verification succeeds

### Phase 5 — Local Integration / Quality
Goal:
- prove the system works together locally

Typical includes:
- app + api + db local integration
- smoke tests
- build verification
- baseline UX hardening
- error, loading, and empty states
- design token cleanup

Done when:
- local run is reproducible
- build succeeds
- smoke verification succeeds
- critical type or runtime errors are resolved

### Phase 6 — Infra / Deployment Base
Goal:
- create deployable structure for later use

Typical includes:
- production-ish compose
- reverse proxy config
- deployment scripts
- monitoring skeleton or profile separation

Done when:
- infra files are coherent
- deployment path is documented
- production-like local path is understandable

### Phase 7 — CI/CD Automation
Goal:
- automate previously proven local workflows

Typical includes:
- CI workflows
- image build and publish
- deployment automation

Done when:
- CI reproduces local-successful checks
- automation path is documented and coherent

### Phase 8 — Hardening
Goal:
- make the project durable for long-term maintenance

Typical includes:
- seed or example data
- stronger tests
- error handling improvements
- ops docs
- regression protection

Done when:
- a new developer can reproduce the project locally
- sample flows work
- operational docs are actionable

---

## 9. Phase Gate Rules

1. Each phase must have:
   - explicit scope
   - explicit deliverables
   - explicit verification commands
   - explicit completion summary

2. Before entering a new phase:
   - confirm the previous phase verification succeeded
   - document any intentional carry-over issues
   - create or switch to the corresponding phase branch if needed

3. If the current phase cannot be fully completed:
   - do not silently continue into the next phase
   - report the exact remaining blockers

---

## 10. Implementation Plan Requirements

`docs/architecture/implementation-plan.md` must contain:

1. project summary
2. current phase
3. official phase list
4. current phase scope and non-scope
5. architecture summary
6. directory structure summary
7. decisions and rationale
8. assumptions or defaults chosen
9. verification plan
10. known blockers or user-action-required items
11. next phase preview, brief only

This file must be updated when the current phase meaningfully changes.

---

## 11. Verification Policy

### 11.1 Verification hierarchy
Prefer this order where applicable:
1. install
2. lint
3. typecheck
4. build
5. test
6. smoke run
7. manual verification notes

### 11.2 Verification rules
- Run the commands that actually prove the claim.
- Read the output.
- Report the result precisely.
- If verification fails, fix first; do not declare done.

### 11.3 Minimum evidence in final report
Include:
- commands run
- pass or fail result
- important warnings or skipped items
- remaining blockers, if any

---

## 12. Reporting Format

For meaningful progress updates, use this structure:

### Progress Update
- Current phase:
- Branch:
- What was completed:
- What is in progress:
- What is blocked:
- Next step:

For final phase completion, use this structure:

### Phase Completion Report
- Phase:
- Branch:
- Deliverables created or updated:
- Key decisions:
- Verification commands:
- Verification results:
- Known limitations:
- User action required:
- Recommended next phase:

---

## 13. Tool and Dependency Policy

1. Prefer official tooling for the selected stack.
2. Avoid unnecessary framework churn.
3. Avoid adding heavy dependencies without strong justification.
4. If a dependency is added:
   - explain why
   - keep the choice consistent with project direction
5. Prefer ownership and maintainability over trendy tooling.

---

## 14. Documentation Policy

1. README must always be usable by a human developer.
2. Major architectural decisions should be captured in ADRs.
3. Runbooks should explain how to run, recover, or inspect the project locally.
4. If a decision is made automatically, document it if it would be non-obvious later.

---

## 15. Generic Quality Rules

1. Keep naming consistent.
2. Keep folder boundaries clear.
3. Prefer simple module boundaries.
4. Avoid premature abstraction.
5. Avoid fake implementations presented as complete features.
6. Keep placeholder text clearly marked.
7. Prefer typed contracts or interfaces where applicable.
8. Ensure local developer experience is not ignored.

---

## 16. User Override Policy

If the user later gives a direct instruction such as:
- “only do Phase 1”
- “use branch-based workflow”
- “do not touch CI/CD”
- “stop at documentation only”

then that instruction overrides the general defaults in this manual.

When overridden:
- continue following the rest of the manual
- do not discard non-conflicting rules

---

## 17. Project-Specific Fill-In Section

Replace the placeholders below for the actual project.

### Project name
- [PROJECT_NAME]

### Project type
- [WEB_APP | API | CLI | MONOREPO | LANDING_PAGE | INTERNAL_TOOL | OTHER]

### Primary stack
- [STACK]

### Package manager
- [PNPM | NPM | YARN | BUN | OTHER]

### Local services expected
- [NONE | DB | CACHE | QUEUE | SEARCH | OTHER]

### Local verification commands
- Install: `[INSTALL_COMMAND]`
- Dev: `[DEV_COMMAND]`
- Build: `[BUILD_COMMAND]`
- Lint: `[LINT_COMMAND]`
- Typecheck: `[TYPECHECK_COMMAND]`
- Test: `[TEST_COMMAND]`
- Smoke: `[SMOKE_COMMAND]`

### Explicit non-goals for now
- [NON_GOAL_1]
- [NON_GOAL_2]
- [NON_GOAL_3]

### User-action-required categories
- [SECRETS]
- [EXTERNAL_AUTH]
- [DNS]
- [REMOTE_SERVER]
- [PAYMENT]
- [ETC]

---

## 18. Recommended Minimal `AGENTS.md`

If the repository does not already have a suitable `AGENTS.md`, use this minimal version:

```md
# AGENTS.md

Follow `project_manual.md` as the project execution source of truth.

Additional rules:
- Work phase-by-phase only.
- Do not work directly on main/master.
- Use a dedicated branch per phase.
- Do not skip local verification.
- Stop and report if user action, credentials, external auth, or permission escalation is required.
- Update `docs/architecture/implementation-plan.md` before and during execution.
- Do not start the next phase unless explicitly instructed.
```

---

## 19. Start Procedure

When execution begins, follow this order:

1. identify repository root
2. confirm current branch and branch policy
3. read this manual fully
4. create or update `docs/architecture/implementation-plan.md`
5. confirm the active phase
6. execute only the current phase
7. verify locally
8. report with evidence
9. stop unless the user explicitly instructs the next phase

---

## 20. Completion Rule

Do not continue indefinitely across all phases by default.
After the active phase is completed and verified:
- report clearly
- recommend the next phase
- wait for user approval unless the user explicitly requested multi-phase continuation

