# Troubleshooting Runbook

## Common Issues

### `apt-get not found`
- Expected on non-Debian systems.
- `dev-env` targets Debian/Ubuntu for v1.
- Use `./dev-env packages --dry-run` to confirm the planned package command without mutating the host.

### `curl not found` or `git not found`
- Run `./dev-env packages` on a supported Debian/Ubuntu machine.
- For local repo verification, `./dev-env test` uses temp PATH shims and should still pass.

### Oh My Zsh/plugins missing during `doctor` or `verify`
- Run `./dev-env bootstrap --no-packages --profile <name>` after dependencies are available.
- Use `./dev-env plugins --profile <name>` if only plugin installation is missing.

### Personal legacy init is wanted on purpose
- Use `./dev-env configure --profile personal` to opt into your own `clear`, `python3 ~/.bg.py`, and `ls` startup commands.
- This keeps the global defaults safe while preserving your personal shell experience.

### Legacy startup effects still present
- Re-run `./dev-env configure --profile <name>`.
- Confirm `~/.zshrc` no longer contains `# init-zsh`, `python3 ~/.bg.py`, or bare `ls` lines.

### Backup or rollback confusion
- List backups with `./dev-env backups-list`.
- Roll back with `./dev-env rollback --backup-file <path> --target <path>`.
- Clean backups only after checking the dry-run output from `./dev-env clean-backups`.

### Packaging smoke fails
- Ensure `dpkg-deb`, `dpkg-scanpackages`, and `apt-ftparchive` are available.
- Re-run `make package-deb VERSION=<version>` and then `./tests/phase3-packaging-smoke.sh`.

### GitHub release/APT publish steps blocked
- This is expected locally until the user provides auth and, if needed, GPG passphrase input.
- Use the release checklist and publish workflow docs instead of attempting live publish during repo verification.
