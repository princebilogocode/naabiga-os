#!/usr/bin/env bash
# Installe Playwright (CLI globale + navigateurs + dépendances système)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

command -v npm >/dev/null 2>&1 || { echo "npm est requis : nos sdk install node lts"; exit 1; }

npm install -g playwright
if [ "$(id -u)" -eq 0 ]; then
  npx playwright install-deps
else
  sudo "$(command -v npx)" playwright install-deps || sudo npx playwright install-deps
fi
npx playwright install chromium firefox webkit
echo "Playwright installé : npx playwright --version"
