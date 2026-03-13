#!/usr/bin/env bash
set -euo pipefail

STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
OUTPUT_DIR=${OUTPUT_DIR:-"$STATE_HOME/dev-env/gpg"}
KEY_NAME=${KEY_NAME:-"dev-env APT Signing Key"}
KEY_EMAIL=${KEY_EMAIL:-"dev-env@example.invalid"}
KEY_COMMENT=${KEY_COMMENT:-"GitHub APT repo signing"}
KEY_TYPE=${KEY_TYPE:-"RSA"}
KEY_LENGTH=${KEY_LENGTH:-"4096"}
KEY_EXPIRE=${KEY_EXPIRE:-"2y"}
KEY_PASSPHRASE=${KEY_PASSPHRASE:-""}
RESET_GNUPGHOME=${RESET_GNUPGHOME:-"0"}

if ! command -v gpg > /dev/null 2>&1; then
  echo "gpg not found. Install gnupg first." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
export GNUPGHOME="$OUTPUT_DIR/.gnupg"
if [ "$RESET_GNUPGHOME" = "1" ] && [ -d "$GNUPGHOME" ]; then
  rm -rf "$GNUPGHOME"
fi
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

batch_file="$(mktemp)"
cleanup() {
  rm -f "$batch_file"
}
trap cleanup EXIT

{
  echo "Key-Type: $KEY_TYPE"
  echo "Key-Length: $KEY_LENGTH"
  echo "Name-Real: $KEY_NAME"
  echo "Name-Email: $KEY_EMAIL"
  echo "Name-Comment: $KEY_COMMENT"
  echo "Expire-Date: $KEY_EXPIRE"
  if [ -n "$KEY_PASSPHRASE" ]; then
    echo "Passphrase: $KEY_PASSPHRASE"
  else
    echo "%no-protection"
  fi
  echo "%commit"
} > "$batch_file"

gpg_status="$(gpg --batch --yes --pinentry-mode loopback --status-fd 1 --generate-key "$batch_file" 2> /dev/null)"
key_fpr="$(printf '%s\n' "$gpg_status" | awk '/^\[GNUPG:\] KEY_CREATED / { print $4; exit }')"
if [ -z "$key_fpr" ]; then
  key_fpr="$(gpg --list-secret-keys --with-colons "$KEY_EMAIL" | awk -F: '$1=="sec"{want=1;next} want&&$1=="fpr"{fpr=$10; want=0} END{print fpr}')"
fi
[ -n "$key_fpr" ] || {
  echo "Failed to resolve key fingerprint." >&2
  exit 1
}

key_id="$(gpg --list-secret-keys --with-colons "$key_fpr" | awk -F: '$1=="sec"{print $5; exit}')"
[ -n "$key_id" ] || {
  echo "Failed to resolve key id." >&2
  exit 1
}

private_key_file="$OUTPUT_DIR/private.key.asc"
public_key_file="$OUTPUT_DIR/public.key.asc"
secrets_env_file="$OUTPUT_DIR/apt-secrets.env"

gpg --batch --yes --pinentry-mode loopback --passphrase "$KEY_PASSPHRASE" --armor --export-secret-keys "$key_fpr" > "$private_key_file"
gpg --armor --export "$key_fpr" > "$public_key_file"

{
  echo "# GitHub Actions secrets helper"
  printf 'APT_GPG_KEY_ID=%q\n' "$key_id"
  printf 'APT_GPG_PASSPHRASE=%q\n' "$KEY_PASSPHRASE"
  printf 'APT_GPG_PRIVATE_KEY_FILE=%q\n' "$private_key_file"
} > "$secrets_env_file"

echo "Generated GPG key."
echo "KEY_ID: $key_id"
echo "Private key: $private_key_file"
echo "Public key:  $public_key_file"
echo "Secrets env: $secrets_env_file"
