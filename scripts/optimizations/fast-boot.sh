#!/usr/bin/env bash
# Démarrage rapide : services inutiles désactivés, délai d'attente réseau réduit
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
command -v systemctl >/dev/null 2>&1 || exit 0

# NetworkManager-wait-online bloque le boot sans réseau (fréquent en salle de TP)
$SUDO systemctl disable NetworkManager-wait-online.service >/dev/null 2>&1 || true
$SUDO systemctl mask systemd-networkd-wait-online.service >/dev/null 2>&1 || true
# Pas d'impression ni de Bluetooth par défaut sur un poste de dev (réactivables)
$SUDO systemctl disable cups-browsed.service >/dev/null 2>&1 || true
# Délais d'arrêt plus courts
$SUDO mkdir -p /etc/systemd/system.conf.d
$SUDO tee /etc/systemd/system.conf.d/90-naabiga.conf >/dev/null <<'EOF'
[Manager]
DefaultTimeoutStopSec=10s
DefaultTimeoutStartSec=30s
EOF
# Journal limité
$SUDO mkdir -p /etc/systemd/journald.conf.d
$SUDO tee /etc/systemd/journald.conf.d/90-naabiga.conf >/dev/null <<'EOF'
[Journal]
SystemMaxUse=200M
EOF
echo "Démarrage rapide configuré."
