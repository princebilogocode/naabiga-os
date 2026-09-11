#!/usr/bin/env bash
# Vérification : fichier ~/.nos/env.sh chargé par le shell
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register nos_env "Profil N-OS (~/.nos/env.sh)" "Environnement"

check_nos_env() {
  if [ ! -f "$NOS_ENV_FILE" ]; then
    doctor_result warn "fichier absent" "nos doctor --repair (crée ~/.nos/env.sh et l'ajoute au .bashrc)"
    return
  fi
  local rc loaded=0
  for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$rc" ] && grep -q '.nos/env.sh' "$rc" && loaded=1
  done
  [ -f /etc/profile.d/nos.sh ] && loaded=1
  if [ "$loaded" = 0 ]; then
    doctor_result warn "présent mais non chargé par le shell" "nos doctor --repair"
    return
  fi
  doctor_result ok "$NOS_ENV_FILE chargé au démarrage du shell"
}

repair_nos_env() {
  mkdir -p "$NOS_HOME"
  [ -f "$NOS_ENV_FILE" ] || printf '# Généré par N-OS — variables d'\''environnement de développement\n' > "$NOS_ENV_FILE"
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] && nos_ensure_line '[ -f "$HOME/.nos/env.sh" ] && . "$HOME/.nos/env.sh"' "$rc"
  done
  [ -f "$HOME/.bashrc" ] || nos_ensure_line '[ -f "$HOME/.nos/env.sh" ] && . "$HOME/.nos/env.sh"' "$HOME/.bashrc"
  return 0
}
