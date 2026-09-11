#!/usr/bin/env bash
# Installe Docker Engine + plugin Compose depuis le dépôt officiel Docker (socle noble)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker est déjà installé : $(docker --version)"
  exit 0
fi

# shellcheck disable=SC1091
. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-noble}}"

$SUDO apt-get update
$SUDO apt-get install -y --no-install-recommends ca-certificates curl gnupg
$SUDO install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
$SUDO chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null
$SUDO apt-get update
$SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

$SUDO groupadd -f docker
TARGET_USER="${SUDO_USER:-$(id -un)}"
if [ "$TARGET_USER" != "root" ]; then
  $SUDO usermod -aG docker "$TARGET_USER"
fi

if command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl enable --now docker || true
fi

echo "Docker installé. Reconnectez-vous pour utiliser docker sans sudo."
