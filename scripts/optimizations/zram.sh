#!/usr/bin/env bash
# ZRAM : swap compressé en mémoire (50 % de la RAM, zstd) — évite le swap disque sur SSD
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if ! dpkg -s zram-tools >/dev/null 2>&1; then
  $SUDO apt-get install -y --no-install-recommends zram-tools || exit 0
fi
$SUDO tee /etc/default/zramswap >/dev/null <<'EOF'
# Naabiga OS — configuration ZRAM
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF
$SUDO systemctl enable --now zramswap.service >/dev/null 2>&1 || $SUDO systemctl restart zramswap.service 2>/dev/null || true
echo "ZRAM configuré (zstd, 50 % de la RAM)."
