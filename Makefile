SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

CLI ?= ./dev-env
PROFILE ?= minimal
REQUEST_FILE ?= config/user/request.txt
VERSION ?= 0.3.0-dev
PACKAGE_ARCH ?= all
DEB_OUTPUT_DIR ?= $(CURDIR)/dist/deb
APT_OUTPUT_DIR ?= $(CURDIR)/dist/apt
APT_DISTRIBUTION ?= stable
GPG_OUTPUT_DIR ?= $(HOME)/.local/state/dev-env/gpg
GITHUB_REPO ?=

.PHONY: help bootstrap packages ohmyzsh plugins configure apply-user doctor test verify smoke \
	backups-list rollback clean-backups chsh package-deb package-apt-repo package-smoke gpg-generate github-secrets-apply install-local \
	lint format-check format release-preflight

help:
	@echo "dev-env — Phase 4 Hardening and Polish"
	@echo
	@echo "Core verification:"
	@echo "  make lint"
	@echo "  make format-check"
	@echo "  ./dev-env test"
	@echo "  make verify"
	@echo
	@echo "CLI commands:"
	@echo "  make bootstrap PROFILE=$(PROFILE)"
	@echo "  make packages / ohmyzsh / plugins / configure / apply-user / doctor / test"
	@echo "  make backups-list / rollback / clean-backups / chsh"
	@echo
	@echo "Packaging commands:"
	@echo "  make package-deb VERSION=$(VERSION)"
	@echo "  make package-apt-repo VERSION=$(VERSION)"
	@echo "  make package-smoke"
	@echo "  make gpg-generate"
	@echo "  make github-secrets-apply GITHUB_REPO=<owner/repo>"
	@echo "  make install-local PREFIX=$$HOME/.local"

bootstrap:
	@$(CLI) bootstrap --profile "$(PROFILE)"

packages:
	@$(CLI) packages

ohmyzsh:
	@$(CLI) ohmyzsh --profile "$(PROFILE)"

plugins:
	@$(CLI) plugins --profile "$(PROFILE)"

configure:
	@$(CLI) configure --profile "$(PROFILE)"

apply-user:
	@$(CLI) apply-user --request-file "$(REQUEST_FILE)"

doctor:
	@$(CLI) doctor --profile "$(PROFILE)"

test:
	@$(CLI) test

lint:
	@./scripts/ci/lint.sh

format-check:
	@./scripts/ci/format-check.sh

format:
	@./scripts/ci/format.sh

verify:
	@$(MAKE) --no-print-directory lint
	@$(MAKE) --no-print-directory format-check
	@tests/smoke/phase2-cli-smoke.sh
	@$(CLI) test
	@tests/phase3-packaging-smoke.sh

release-preflight: verify

smoke:
	@tests/smoke/phase2-cli-smoke.sh

backups-list:
	@$(CLI) backups-list

rollback:
	@$(CLI) rollback

clean-backups:
	@$(CLI) clean-backups

chsh:
	@$(CLI) chsh

package-deb:
	@VERSION="$(VERSION)" PACKAGE_ARCH="$(PACKAGE_ARCH)" OUTPUT_DIR="$(DEB_OUTPUT_DIR)" ./packaging/build-deb.sh "$(VERSION)"

package-apt-repo: package-deb
	@DEB_FILE="$$(ls -1 $(DEB_OUTPUT_DIR)/dev-env_*_$(PACKAGE_ARCH).deb | tail -n 1)"; \
	GPG_KEY_ID="$(GPG_KEY_ID)" GPG_PASSPHRASE="$(GPG_PASSPHRASE)" ./packaging/build-apt-repo.sh "$$DEB_FILE" "$(APT_OUTPUT_DIR)" "$(APT_DISTRIBUTION)"

package-smoke:
	@./tests/phase3-packaging-smoke.sh

gpg-generate:
	@OUTPUT_DIR="$(GPG_OUTPUT_DIR)" KEY_NAME="$(GPG_KEY_NAME)" KEY_EMAIL="$(GPG_KEY_EMAIL)" KEY_COMMENT="$(GPG_KEY_COMMENT)" KEY_EXPIRE="$(GPG_KEY_EXPIRE)" KEY_PASSPHRASE="$(GPG_PASSPHRASE)" ./packaging/generate-gpg-key.sh

github-secrets-apply:
	@REPO="$(GITHUB_REPO)" KEY_ID="$(GPG_KEY_ID)" PASSPHRASE="$(GPG_PASSPHRASE)" PRIVATE_KEY_FILE="$(GPG_OUTPUT_DIR)/private.key.asc" SECRETS_ENV_FILE="$(GPG_OUTPUT_DIR)/apt-secrets.env" ./packaging/github-secrets-apply.sh

install-local:
	@./install.sh --prefix "$${PREFIX:-$$HOME/.local}"
