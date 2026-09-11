#!/usr/bin/env bash
# Vérification : espace disque (Android Studio + SDK + Flutter ≈ 15 Go)
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register disk "Espace disque" "Système"

check_disk() {
  nos_has df || { doctor_result warn "df indisponible"; return; }
  local avail_kb
  avail_kb="$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')"
  [ -n "$avail_kb" ] || { doctor_result warn "impossible de lire l'espace disque"; return; }
  local avail_gb=$(( avail_kb / 1024 / 1024 ))
  if [ "$avail_gb" -lt 5 ]; then
    doctor_result fail "${avail_gb} Go libres dans \$HOME — insuffisant" "Libérez de l'espace : sudo apt clean ; flutter clean ; docker system prune"
  elif [ "$avail_gb" -lt 20 ]; then
    doctor_result warn "${avail_gb} Go libres dans \$HOME — 20 Go recommandés pour Android Studio + Flutter" "docker system prune ; sudo apt clean"
  else
    doctor_result ok "${avail_gb} Go libres dans \$HOME"
  fi
}
