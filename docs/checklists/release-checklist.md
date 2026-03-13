# Release Checklist

## Core local verification
- [ ] `make lint`
- [ ] `make format-check`
- [ ] `./dev-env test`
- [ ] `./tests/phase3-packaging-smoke.sh`
- [ ] `make verify`

## Release artifact review
- [ ] inspect `dist/deb/dev-env_<version>_all.deb`
- [ ] inspect package metadata with `dpkg-deb -I`
- [ ] inspect package contents with `dpkg-deb -c`
- [ ] confirm local install path docs are current
- [ ] confirm GitHub workflow files are current

## Optional GitHub Pages APT release prep
- [ ] `gpg --version`
- [ ] `gh --version`
- [ ] `make gpg-generate GPG_KEY_EMAIL=<email> GPG_PASSPHRASE='<passphrase>'`
- [ ] `make github-secrets-apply GITHUB_REPO=<owner/repo>`
- [ ] verify `.github/workflows/publish-apt-repo.yml`
- [ ] verify `.github/workflows/ci.yml`
- [ ] verify GitHub Pages configuration for `gh-pages`

## Release notes
- [ ] draft notes from `docs/release-notes-template.md`
- [ ] summarize CLI / packaging / verification changes

## Publish gates
- [ ] tag/version chosen
- [ ] changelog/release summary prepared
- [ ] credentials/auth steps completed by the user if publishing is actually required
