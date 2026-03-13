#!/usr/bin/env bash
set -euo pipefail

SUDO=${SUDO:-sudo}
APT_PACKAGES=${APT_PACKAGES:-"git curl zsh build-essential"}
APT_GET_UPDATE_OPTS=${APT_GET_UPDATE_OPTS:-"-o Acquire::Retries=3"}
APT_GET_INSTALL_OPTS=${APT_GET_INSTALL_OPTS:-"-y -o Dpkg::Use-Pty=0 -o Acquire::Retries=3"}
BREW_PACKAGES=${BREW_PACKAGES:-"git curl zsh"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib.sh
source "$SCRIPT_DIR/lib.sh"

if is_macos; then
  brew_bin="$(command -v brew || true)"
  if [ -z "$brew_bin" ]; then
    if is_dry_run; then
      brew_bin='brew'
    else
      die "Homebrew not found. Install Homebrew first, then re-run 'envkit packages'."
    fi
  fi

  read -r -a brew_packages <<< "$BREW_PACKAGES"
  run_cmd "$brew_bin" update
  run_cmd "$brew_bin" install "${brew_packages[@]}"
  exit 0
fi

apt_get_bin="$(command -v apt-get || true)"
if [ -z "$apt_get_bin" ]; then
  if is_dry_run; then
    apt_get_bin='apt-get'
  else
    die 'apt-get not found. This task assumes Debian/Ubuntu.'
  fi
fi

read -r -a apt_update_opts <<< "$APT_GET_UPDATE_OPTS"
read -r -a apt_install_opts <<< "$APT_GET_INSTALL_OPTS"
read -r -a apt_packages <<< "$APT_PACKAGES"

run_cmd "$SUDO" env DEBIAN_FRONTEND=noninteractive "$apt_get_bin" "${apt_update_opts[@]}" update
run_cmd "$SUDO" env DEBIAN_FRONTEND=noninteractive "$apt_get_bin" "${apt_install_opts[@]}" install "${apt_packages[@]}"
