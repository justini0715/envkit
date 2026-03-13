#!/usr/bin/env bash
set -euo pipefail

STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
REPO=${REPO:-""}
KEY_ID=${KEY_ID:-""}
PASSPHRASE=${PASSPHRASE:-""}
PRIVATE_KEY_FILE=${PRIVATE_KEY_FILE:-"$STATE_HOME/dev-env/gpg/private.key.asc"}
SECRETS_ENV_FILE=${SECRETS_ENV_FILE:-"$STATE_HOME/dev-env/gpg/apt-secrets.env"}

resolve_repo_from_git() {
  local remote_url
  remote_url="$(git config --get remote.origin.url 2> /dev/null || true)"
  if [ -z "$remote_url" ]; then
    return 1
  fi

  case "$remote_url" in
    git@github.com:*.git)
      remote_url="${remote_url#git@github.com:}"
      echo "${remote_url%.git}"
      ;;
    https://github.com/*.git)
      remote_url="${remote_url#https://github.com/}"
      echo "${remote_url%.git}"
      ;;
    https://github.com/*)
      echo "${remote_url#https://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac
}

if ! command -v gh > /dev/null 2>&1; then
  echo "gh CLI not found. Install GitHub CLI first." >&2
  exit 1
fi

if ! gh auth status > /dev/null 2>&1; then
  echo "gh auth is not ready. Run: gh auth login" >&2
  exit 1
fi

if [ -f "$SECRETS_ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$SECRETS_ENV_FILE"
  KEY_ID="${KEY_ID:-${APT_GPG_KEY_ID:-}}"
  PASSPHRASE="${PASSPHRASE:-${APT_GPG_PASSPHRASE:-}}"
  PRIVATE_KEY_FILE="${PRIVATE_KEY_FILE:-${APT_GPG_PRIVATE_KEY_FILE:-$PRIVATE_KEY_FILE}}"
fi

if [ -z "$REPO" ]; then
  REPO="$(resolve_repo_from_git || true)"
fi

[ -n "$REPO" ] || {
  echo "Cannot resolve repository. Set REPO=owner/repo." >&2
  exit 1
}
[ -n "$KEY_ID" ] || {
  echo "KEY_ID is empty. Set KEY_ID or provide SECRETS_ENV_FILE." >&2
  exit 1
}
[ -f "$PRIVATE_KEY_FILE" ] || {
  echo "Private key file not found: $PRIVATE_KEY_FILE" >&2
  exit 1
}

gh secret set APT_GPG_PRIVATE_KEY --repo "$REPO" < "$PRIVATE_KEY_FILE"
printf '%s' "$KEY_ID" | gh secret set APT_GPG_KEY_ID --repo "$REPO" --body -

if [ -n "$PASSPHRASE" ]; then
  printf '%s' "$PASSPHRASE" | gh secret set APT_GPG_PASSPHRASE --repo "$REPO" --body -
  echo "Applied secrets: APT_GPG_PRIVATE_KEY, APT_GPG_KEY_ID, APT_GPG_PASSPHRASE"
else
  echo "Applied secrets: APT_GPG_PRIVATE_KEY, APT_GPG_KEY_ID"
  echo "APT_GPG_PASSPHRASE was skipped (empty)."
fi

echo "Repository: $REPO"
