# Packaging Overview

Phase 3 adds standalone packaging and release helpers:
- `build-deb.sh`
- `build-apt-repo.sh`
- `generate-gpg-key.sh`
- `github-secrets-apply.sh`

Generated GPG material defaults to `${XDG_STATE_HOME:-$HOME/.local/state}/envkit/gpg` rather than tracked repo output.
