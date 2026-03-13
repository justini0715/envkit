# Developer Guide

## Purpose
This is the human-maintainer guide for `envkit`.
It covers the practical rules for changing, verifying, packaging, and releasing the project without having to reverse-engineer the automation.

## Repository Rules
- default branch: `main`
- do not develop directly on `main`
- create a short-lived working branch for every follow-up change
- merge through PR after CI is green

## Local Verification Cheat Sheet
```bash
make lint
make format-check
./envkit test
./tests/phase3-packaging-smoke.sh
make verify
```

## CLI Smoke Commands
```bash
envkit help
envkit bootstrap --dry-run --no-packages --profile minimal
envkit doctor --profile minimal
envkit configure --profile personal
```

## Packaging / Release Cheat Sheet
```bash
make package-deb VERSION=0.4.1-test
./tests/phase3-packaging-smoke.sh
```

## Signed APT Repository
Current signed APT repo base:
- `https://justini0715.github.io/envkit`

Public key:
- `https://justini0715.github.io/envkit/public.key`

The publish workflow signs the repo when these secrets exist:
- `APT_GPG_KEY_ID`
- `APT_GPG_PRIVATE_KEY`
- optional `APT_GPG_PASSPHRASE`

Local signing material is stored outside the repo tree by default:
- `${XDG_STATE_HOME:-$HOME/.local/state}/envkit/gpg`

## Release Workflow
1. work on a non-main branch
2. run local verification
3. push branch and open PR
4. wait for CI to pass
5. merge to `main`
6. create and push a tag (for example `v0.4.1`)
7. confirm:
   - GitHub release asset uploaded
   - GitHub Pages deploy succeeded
   - `InRelease` / `public.key` / `Packages` are accessible

## GitHub Pages Notes
- the Pages root now publishes an `index.html` landing page
- the actual APT metadata lives under `dists/stable/...`
- if Pages deploy fails, first inspect `github-pages` environment rules and tag/branch policy

## Brownfield Reference Rule
The old source reference remains:
- `/home/iostream/Desktop/dev-env`

Use it only as a brownfield reference. Do not copy its old repo layout or reintroduce unsafe default startup behavior.

## Recommended Maintainer Habit
Before any release, check these in order:
1. `make lint`
2. `make format-check`
3. `./envkit test`
4. `./tests/phase3-packaging-smoke.sh`
5. `make verify`
6. latest PR CI status
7. latest tag publish workflow status
