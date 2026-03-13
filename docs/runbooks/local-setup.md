# Local Setup Runbook

## Purpose
Describe the supported standalone `envkit` workflow after the v0.4.0 release.

## Preconditions
- work from the `envkit` repository root
- use a non-`main` working branch when making follow-up changes
- treat `/home/iostream/Desktop/dev-env` as brownfield-reference input only

## Recommended Local Commands
```bash
make lint
make format-check
./envkit bootstrap --dry-run --no-packages --profile minimal
./envkit test
make package-deb VERSION=0.3.0-test
./tests/phase3-packaging-smoke.sh
make verify
```

## Local Install Path
```bash
./install.sh --prefix "$HOME/.local"
```

## Signed APT Install
```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://justini0715.github.io/envkit/public.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/envkit-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/envkit-archive-keyring.gpg] https://justini0715.github.io/envkit stable main" \
  | sudo tee /etc/apt/sources.list.d/envkit.list >/dev/null

sudo apt update
sudo apt install -y envkit
```

## After Install
```bash
envkit help
envkit bootstrap --no-packages --profile minimal
envkit doctor --profile minimal
```

## macOS (Experimental)

Current scope:
- package/bootstrap/configure/doctor flows work with Homebrew-based prerequisites
- APT/.deb packaging remains Linux-only

Suggested macOS bootstrap path:

```bash
brew install git curl zsh
./install.sh --prefix "$HOME/.local"
$HOME/.local/bin/envkit bootstrap --no-packages --profile minimal
```

## Personal Opt-In Profile

To restore your own interactive startup commands without making them global defaults:

```bash
./envkit configure --profile personal
```

This uses `config/user/personal-request.txt` and writes the commands into the managed user drop-in instead of forcing them into the default bootstrap path.

## Release Readiness Path
- use `make release-preflight` for the full local gate
- use `docs/checklists/release-checklist.md` before tagging
- use `docs/release-notes-template.md` to draft release notes
- use `docs/runbooks/developer-guide.md` for maintainer-focused workflow notes
