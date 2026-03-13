#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: packaging/build-apt-repo.sh <deb_file> [output_dir] [distribution]" >&2
  exit 1
fi

deb_file="$1"
output_dir="${2:-dist/apt}"
distribution="${3:-stable}"
component="${COMPONENT:-main}"
origin="${REPO_ORIGIN:-dev-env}"
label="${REPO_LABEL:-dev-env}"
description="${REPO_DESCRIPTION:-dev-env apt repository}"
suite="${REPO_SUITE:-$distribution}"
codename="${REPO_CODENAME:-$distribution}"
architectures="${REPO_ARCHITECTURES:-amd64 all}"

if [ ! -f "$deb_file" ]; then
  echo "deb file not found: $deb_file" >&2
  exit 1
fi

if ! command -v dpkg-scanpackages > /dev/null 2>&1; then
  echo "dpkg-scanpackages not found. Install dpkg-dev." >&2
  exit 1
fi

if ! command -v apt-ftparchive > /dev/null 2>&1; then
  echo "apt-ftparchive not found. Install apt-utils." >&2
  exit 1
fi

repo_root="$(cd "$(dirname "$output_dir")" && pwd)/$(basename "$output_dir")"
mkdir -p "$repo_root/pool/$component/d/dev-env"

deb_name="$(basename "$deb_file")"
cp -f "$deb_file" "$repo_root/pool/$component/d/dev-env/$deb_name"

for arch in amd64 all; do
  mkdir -p "$repo_root/dists/$distribution/$component/binary-$arch"
done

(
  cd "$repo_root"
  dpkg-scanpackages --multiversion "pool/$component" /dev/null > "dists/$distribution/$component/binary-amd64/Packages"
  cp "dists/$distribution/$component/binary-amd64/Packages" "dists/$distribution/$component/binary-all/Packages"
  gzip -9c "dists/$distribution/$component/binary-amd64/Packages" > "dists/$distribution/$component/binary-amd64/Packages.gz"
  gzip -9c "dists/$distribution/$component/binary-all/Packages" > "dists/$distribution/$component/binary-all/Packages.gz"
)

release_conf="$(mktemp)"
cleanup() {
  rm -f "$release_conf"
}
trap cleanup EXIT

cat > "$release_conf" << EOF_CONF
APT::FTPArchive::Release {
  Origin "$origin";
  Label "$label";
  Suite "$suite";
  Codename "$codename";
  Architectures "$architectures";
  Components "$component";
  Description "$description";
};
EOF_CONF

apt-ftparchive -c "$release_conf" release "$repo_root/dists/$distribution" > "$repo_root/dists/$distribution/Release"

if [ -n "${GPG_KEY_ID:-}" ]; then
  key_id="$(printf '%s' "$GPG_KEY_ID" | tr -d '\r' | awk '{print $1}')"
  passphrase="$(printf '%s' "${GPG_PASSPHRASE:-}" | tr -d '\r')"
  release_file="$repo_root/dists/$distribution/Release"
  gpg_common=(--batch --yes --pinentry-mode loopback --local-user "$key_id")

  sign_detached() {
    local output_file="$1"
    if [ -n "$passphrase" ]; then
      printf '%s' "$passphrase" | gpg "${gpg_common[@]}" --passphrase-fd 0 --armor --detach-sign --output "$output_file" -- "$release_file"
    else
      gpg "${gpg_common[@]}" --armor --detach-sign --output "$output_file" -- "$release_file"
    fi
  }

  sign_inrelease() {
    local output_file="$1"
    if [ -n "$passphrase" ]; then
      printf '%s' "$passphrase" | gpg "${gpg_common[@]}" --passphrase-fd 0 --armor --clearsign --output "$output_file" -- "$release_file"
    else
      gpg "${gpg_common[@]}" --armor --clearsign --output "$output_file" -- "$release_file"
    fi
  }

  sign_detached "$repo_root/dists/$distribution/Release.gpg"
  sign_inrelease "$repo_root/dists/$distribution/InRelease"
  gpg --armor --export "$key_id" > "$repo_root/public.key"
else
  echo "WARN: GPG_KEY_ID not set. Repository is unsigned." >&2
fi

echo "APT repository prepared at: $repo_root"
