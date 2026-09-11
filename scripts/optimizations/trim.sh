#!/usr/bin/env bash
# TRIM automatique hebdomadaire des SSD (fstrim.timer)
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl enable --now fstrim.timer >/dev/null 2>&1 && echo "fstrim.timer activé (TRIM hebdomadaire)."
fi
