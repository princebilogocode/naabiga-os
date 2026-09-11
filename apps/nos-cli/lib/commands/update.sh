#!/usr/bin/env bash
# nos update — met à jour le système, les SDK et les assistants IA
# SPDX-License-Identifier: GPL-3.0-or-later

update_system() {
  nos_title "Mise à jour du système (APT)"
  nos_has apt-get || { nos_warn "apt-get introuvable : étape ignorée."; return 0; }
  nos_sudo apt-get update
  nos_sudo env DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
  nos_sudo apt-get autoremove -y
  if nos_has flatpak; then
    nos_title "Mise à jour Flatpak"
    nos_run flatpak update -y
  fi
}

update_sdk() {
  nos_title "Mise à jour des SDK"
  if nos_has flutter; then nos_run flutter upgrade; fi
  if nos_has npm; then nos_run npm update -g; fi
  if nos_has sdkmanager; then nos_run sdkmanager --update; fi
}

update_ai() {
  nos_title "Mise à jour des assistants IA"
  # shellcheck source=../../../nos-ai/lib/ai.sh
  source "$NOS_AI_LIB/ai.sh"
  ai_update_all
}

cmd_update() {
  local do_system=0 do_sdk=0 do_ai=0
  if [ $# -eq 0 ]; then do_system=1; do_sdk=1; do_ai=1; fi
  while [ $# -gt 0 ]; do
    case "$1" in
      --system) do_system=1 ;;
      --sdk)    do_sdk=1 ;;
      --ai)     do_ai=1 ;;
      --all)    do_system=1; do_sdk=1; do_ai=1 ;;
      -h|--help) printf 'Usage : nos update [--system] [--sdk] [--ai] [--all]\n'; return 0 ;;
      *) nos_die "Option inconnue : $1" ;;
    esac
    shift
  done
  [ "$do_system" = 1 ] && update_system
  [ "$do_sdk" = 1 ] && update_sdk
  [ "$do_ai" = 1 ] && update_ai
  nos_ok "Mise à jour terminée."
}
