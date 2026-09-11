#!/usr/bin/env bash
# Premier démarrage : pare-feu UFW activé, mises à jour de sécurité automatiques, AppArmor
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v ufw >/dev/null 2>&1; then
  $SUDO ufw default deny incoming >/dev/null
  $SUDO ufw default allow outgoing >/dev/null
  # Ports de développement courants autorisés depuis le réseau local uniquement
  for port in 3000 5173 8000 8080; do
    $SUDO ufw allow from 10.0.0.0/8 to any port "$port" proto tcp >/dev/null 2>&1 || true
    $SUDO ufw allow from 192.168.0.0/16 to any port "$port" proto tcp >/dev/null 2>&1 || true
  done
  $SUDO ufw --force enable >/dev/null
  echo "UFW activé."
fi

if command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl enable --now apparmor >/dev/null 2>&1 || true
  $SUDO systemctl enable --now unattended-upgrades >/dev/null 2>&1 || true
fi

if [ -d /etc/apt/apt.conf.d ] && [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
  printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' | $SUDO tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
fi
