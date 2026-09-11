#!/usr/bin/env bash
# Optimisation Docker : journaux limités, BuildKit, overlay2, miroir configurable
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

$SUDO mkdir -p /etc/docker
if [ ! -f /etc/docker/daemon.json ]; then
  $SUDO tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "20m", "max-file": "3" },
  "storage-driver": "overlay2",
  "features": { "buildkit": true },
  "default-address-pools": [ { "base": "172.30.0.0/16", "size": 24 } ]
}
EOF
  echo "Configuration Docker écrite (/etc/docker/daemon.json)."
fi
if command -v docker >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl restart docker >/dev/null 2>&1 || true
fi
# Variables pour BuildKit et Compose côté utilisateur
$SUDO tee /etc/profile.d/nos-docker.sh >/dev/null <<'EOF'
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
EOF
