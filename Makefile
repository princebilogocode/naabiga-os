# Naabiga OS — Makefile racine
# Cibles : help, lint, test, install-cli, uninstall-cli, packages, iso, docs, docs-serve, clean

SHELL := /usr/bin/env bash
VERSION := $(shell tr -d '[:space:]' < VERSION)
DESTDIR ?=
PREFIX ?= /usr

SH_FILES := $(shell find apps scripts build iso/config/hooks tests -type f \( -name '*.sh' -o -name 'nos' -o -name '*.hook.chroot' \) 2>/dev/null)

.PHONY: help lint secrets hooks test test-unit test-integration install-cli uninstall-cli packages iso docs docs-serve clean version

help: ## Afficher cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33m%-18s\033[0m %s\n", $$1, $$2}'

version: ## Afficher la version
	@echo $(VERSION)

lint: secrets ## Vérifier les scripts Bash avec shellcheck (et l'absence de secrets)
	@command -v shellcheck >/dev/null || { echo "shellcheck manquant : sudo apt install shellcheck"; exit 1; }
	shellcheck -x -s bash $(SH_FILES) iso/auto/config
	@echo "lint OK"

secrets: ## Vérifier qu'aucun secret n'est versionné
	bash scripts/check-secrets.sh

hooks: ## Installer le hook Git pre-commit (secrets + shellcheck)
	bash scripts/install-git-hooks.sh

test: test-unit test-integration ## Lancer tous les tests

test-unit: ## Tests unitaires (bats)
	@command -v bats >/dev/null || { echo "bats manquant : sudo apt install bats (ou npm i -g bats)"; exit 1; }
	bats tests/unit

test-integration: ## Tests d'intégration (bash)
	bash tests/integration/run.sh

install-cli: ## Installer la CLI nos sur ce système (sudo)
	DESTDIR="$(DESTDIR)" PREFIX="$(PREFIX)" bash build/install-cli.sh

uninstall-cli: ## Désinstaller la CLI nos
	DESTDIR="$(DESTDIR)" PREFIX="$(PREFIX)" bash build/install-cli.sh --uninstall

packages: ## Construire les paquets .deb (nos-base, nos-branding, nos-cli, nos-desktop)
	bash build/build-packages.sh

iso: packages ## Construire l'ISO (Ubuntu 24.04, sudo requis)
	bash build/build-iso.sh

docs: ## Construire la documentation MkDocs
	mkdocs build --strict

docs-serve: ## Servir la documentation en local
	mkdocs serve

clean: ## Nettoyer les artefacts de build
	rm -rf build/out build/work site tests/.tmp
	@echo "clean OK (pour live-build : cd iso && sudo lb clean --purge)"
