#!/usr/bin/env bash
# Installe Visual Studio Code depuis le dépôt officiel Microsoft (APT)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v code >/dev/null 2>&1; then
  echo "VS Code est déjà installé : $(code --version | head -n 1)"
  exit 0
fi

$SUDO apt-get install -y --no-install-recommends wget gpg apt-transport-https
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | $SUDO tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | $SUDO tee /etc/apt/sources.list.d/vscode.list >/dev/null
$SUDO apt-get update
$SUDO apt-get install -y code

# Extensions recommandées N-OS
if [ -n "${SUDO_USER:-}" ]; then
  RUN_AS="sudo -u $SUDO_USER"
else
  RUN_AS=""
fi
for ext in Dart-Code.flutter Dart-Code.dart-code ms-azuretools.vscode-docker ms-python.python esbenp.prettier-vscode eamodio.gitlens; do
  $RUN_AS code --install-extension "$ext" --force >/dev/null 2>&1 || true
done
echo "VS Code installé."
