# Troubleshooting Runbook

## Common Issues

### `apt-get not found`
- On macOS this is expected. Use Homebrew instead.
- `envkit packages` automatically switches to `brew` when macOS is detected.

- Expected on non-Debian systems.
- `envkit` targets Debian/Ubuntu for v1.
- Use `./envkit packages --dry-run` to confirm the planned package command without mutating the host.

### `curl not found` or `git not found`
- Run `./envkit packages` on a supported Debian/Ubuntu machine.
- For local repo verification, `./envkit test` uses temp PATH shims and should still pass.

### Oh My Zsh/plugins missing during `doctor` or `verify`
- Run `./envkit bootstrap --no-packages --profile <name>` after dependencies are available.
- Use `./envkit plugins --profile <name>` if only plugin installation is missing.

### Personal legacy init is wanted on purpose
- Use `./envkit configure --profile personal` to opt into your own `clear`, `python3 ~/.bg.py`, and `ls` startup commands.
- This keeps the global defaults safe while preserving your personal shell experience.

### Legacy startup effects still present
- Re-run `./envkit configure --profile <name>`.
- Confirm `~/.zshrc` no longer contains `# init-zsh`, `python3 ~/.bg.py`, or bare `ls` lines.

### Backup or rollback confusion
- List backups with `./envkit backups-list`.
- Roll back with `./envkit rollback --backup-file <path> --target <path>`.
- Clean backups only after checking the dry-run output from `./envkit clean-backups`.

### Packaging smoke fails
- Ensure `dpkg-deb`, `dpkg-scanpackages`, and `apt-ftparchive` are available.
- Re-run `make package-deb VERSION=<version>` and then `./tests/phase3-packaging-smoke.sh`.

### GitHub release/APT publish steps blocked
- This is expected locally until the user provides auth and, if needed, GPG passphrase input.
- Use the release checklist and publish workflow docs instead of attempting live publish during repo verification.
