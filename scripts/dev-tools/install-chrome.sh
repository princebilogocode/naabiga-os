#!/usr/bin/env bash
# Installe Google Chrome (logiciel propriétaire, dépôt officiel Google)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v google-chrome >/dev/null 2>&1; then
  echo "Google Chrome est déjà installé."
  exit 0
fi

echo "Google Chrome est un logiciel propriétaire soumis aux conditions de Google."
$SUDO apt-get install -y --no-install-recommends wget gpg
wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | $SUDO tee /usr/share/keyrings/google-chrome.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
  | $SUDO tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
$SUDO apt-get update
$SUDO apt-get install -y google-chrome-stable
echo "Google Chrome installé."
