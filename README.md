# envkit

`envkit` is a Debian/Ubuntu shell bootstrap CLI for setting up a reproducible zsh-based development environment.

It provides:
- package/bootstrap helpers
- Oh My Zsh + plugin setup
- safe zsh configuration management
- doctor / verify / rollback flows
- signed APT distribution via GitHub Pages

## Install with APT

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

## First Commands

```bash
envkit help
envkit bootstrap --no-packages --profile minimal
envkit doctor --profile minimal
```

## Personal Opt-In Profile

If you want your own interactive startup commands back explicitly:

```bash
envkit configure --profile personal
```

## Local Development

```bash
make lint
make format-check
./envkit test
./tests/phase3-packaging-smoke.sh
make verify
```

## Local Install Without APT

```bash
./install.sh --prefix "$HOME/.local"
```

## More Docs

- Maintainer workflow: `docs/runbooks/developer-guide.md`
- Troubleshooting: `docs/runbooks/troubleshooting.md`
- Local setup / install notes: `docs/runbooks/local-setup.md`
- Release checklist: `docs/checklists/release-checklist.md`
- Release notes template: `docs/release-notes-template.md`

## Repository

- GitHub: https://github.com/justini0715/envkit
- APT repo / Pages: https://justini0715.github.io/envkit/
