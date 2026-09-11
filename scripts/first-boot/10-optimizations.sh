#!/usr/bin/env bash
# Premier démarrage : applique les optimisations système N-OS
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

OPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../optimizations" && pwd)"
for s in zram trim ssd fast-boot docker flutter android-studio; do
  [ -f "$OPT/$s.sh" ] && bash "$OPT/$s.sh" || true
done
