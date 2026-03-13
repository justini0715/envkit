# Test Spec — Phase 3 Packaging and Release

## Goal
Verify that the project can build release artifacts and package/release scaffolding locally without requiring credentials or live publishing.

## Test Strategy

### 1. Syntax and existing repo checks
- `bash -n` on shell entrypoints, packaging scripts, and tests
- existing Phase 2 tests remain green

### 2. Packaging build checks
- `make package-deb VERSION=0.3.0-test`
- confirm the `.deb` file exists
- inspect package metadata with `dpkg-deb -I`
- inspect package contents with `dpkg-deb -c`

### 3. Package smoke verification
- unpack the built `.deb` into a temp directory
- execute the packaged `envkit help` wrapper from the unpacked tree
- build an unsigned local APT repo from the `.deb`
- verify `Release`, `Packages`, and `Packages.gz` outputs exist

### 4. Install path verification
- run `install.sh --prefix <tempdir>`
- confirm wrapper and library files are installed coherently

### 5. Documentation sanity
- ensure Phase 3 docs exist and mention the standalone repo paths

## Recommended Command Sequence
```bash
bash -n envkit scripts/*.sh scripts/tasks/*.sh packaging/*.sh install.sh tests/*.sh tests/smoke/*.sh
./envkit test
make package-deb VERSION=0.3.0-test
./tests/phase3-packaging-smoke.sh
make verify
```

## Expected Results
- `.deb` package builds successfully
- package metadata reflects honest runtime dependencies
- package smoke test passes without system install
- install script stages the repo into the requested prefix
- docs and release checklist are present and aligned with the standalone repo
