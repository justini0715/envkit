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
origin="${REPO_ORIGIN:-envkit}"
label="${REPO_LABEL:-envkit}"
description="${REPO_DESCRIPTION:-envkit apt repository}"
suite="${REPO_SUITE:-$distribution}"
codename="${REPO_CODENAME:-$distribution}"
architectures="${REPO_ARCHITECTURES:-amd64 all}"

derive_repo_base_url() {
  if [ -n "${REPO_BASE_URL:-}" ]; then
    printf '%s\n' "$REPO_BASE_URL"
    return 0
  fi

  if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    local owner repo
    owner="${GITHUB_REPOSITORY%/*}"
    repo="${GITHUB_REPOSITORY#*/}"
    printf 'https://%s.github.io/%s\n' "$owner" "$repo"
    return 0
  fi

  printf '%s\n' ''
}

write_index_page() {
  local repo_root=${1:?repo_root is required}
  local base_url distribution component
  base_url="$(derive_repo_base_url)"
  distribution="${2:?distribution is required}"
  component="${3:?component is required}"

  cat > "$repo_root/index.html" << EOF_INDEX
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>envkit APT Repository</title>
    <style>
      body { font-family: system-ui, sans-serif; max-width: 52rem; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
      code, pre { font-family: ui-monospace, monospace; background: #f5f5f5; }
      code { padding: 0.15rem 0.3rem; border-radius: 0.25rem; }
      pre { padding: 1rem; overflow-x: auto; border-radius: 0.5rem; }
      a { color: #0b57d0; }
    </style>
  </head>
  <body>
    <h1>envkit APT Repository</h1>
    <p>This GitHub Pages site serves the signed APT repository for <strong>envkit</strong>.</p>
    <ul>
      <li><a href="public.key">public.key</a></li>
      <li><a href="dists/${distribution}/InRelease">dists/${distribution}/InRelease</a></li>
      <li><a href="dists/${distribution}/${component}/binary-amd64/Packages">Packages</a></li>
    </ul>
    <h2>Install</h2>
    <pre><code>sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL ${base_url:-<your-pages-url>}/public.key \\
  | gpg --dearmor \\
  | sudo tee /etc/apt/keyrings/envkit-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/envkit-archive-keyring.gpg] ${base_url:-<your-pages-url>} ${distribution} ${component}" \\
  | sudo tee /etc/apt/sources.list.d/envkit.list >/dev/null

sudo apt update
sudo apt install -y envkit</code></pre>
  </body>
</html>
EOF_INDEX
}

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
mkdir -p "$repo_root/pool/$component/d/envkit"

deb_name="$(basename "$deb_file")"
cp -f "$deb_file" "$repo_root/pool/$component/d/envkit/$deb_name"

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

write_index_page "$repo_root" "$distribution" "$component"

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
