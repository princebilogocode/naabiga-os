#!/usr/bin/env bash
# Optimisations N-OS — profil Développement (= optimisations système standard)
# Exécuté en root par : nos profile apply dev
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

OPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../optimizations" && pwd)"
for s in zram trim ssd fast-boot docker flutter android-studio; do
  [ -f "$OPT/$s.sh" ] && bash "$OPT/$s.sh" || true
done
echo "Profil Développement : optimisations appliquées."
