#!/usr/bin/env bash
# Exécute tous les scripts de premier démarrage (NN-*.sh) une seule fois
# Lancé par nos-first-boot.service ; marqueur : /var/lib/nos/first-boot.done
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARK="/var/lib/nos/first-boot.done"
LOG="/var/log/nos-first-boot.log"

[ "$(id -u)" -eq 0 ] || { echo "root requis"; exit 1; }
[ -f "$MARK" ] && { echo "Premier démarrage déjà effectué ($MARK)"; exit 0; }
mkdir -p "$(dirname "$MARK")"

{
  echo "=== Naabiga OS — premier démarrage : $(date)"
  for script in "$DIR"/[0-9][0-9]-*.sh; do
    [ -f "$script" ] || continue
    echo "--- $(basename "$script")"
    if bash "$script"; then
      echo "    OK"
    else
      echo "    ÉCHEC (code $?) — poursuite"
    fi
  done
  echo "=== Terminé : $(date)"
} 2>&1 | tee -a "$LOG"

touch "$MARK"
