#!/usr/bin/env bash
# nos remove : désinstalle des outils du catalogue
# SPDX-License-Identifier: GPL-3.0-or-later

remove_one() {
  local id="$1" entry
  if ! entry="$(nos_catalog_lookup "$id")"; then
    nos_err "Outil inconnu : $id"
    return 1
  fi
  local method spec
  method="$(printf '%s' "$entry" | cut -f4)"
  spec="$(printf '%s' "$entry" | cut -f5)"
  nos_title "Désinstallation : $id"
  case "$method" in
    apt)
      # shellcheck disable=SC2086
      nos_apt_remove $spec
      ;;
    flatpak) nos_run flatpak uninstall -y "$spec" ;;
    npm)     nos_run npm uninstall -g "$spec" ;;
    pipx)    nos_run pipx uninstall "$spec" ;;
    sdk)
      # shellcheck source=../../../nos-sdk/lib/sdk.sh
      source "$NOS_SDK_LIB/sdk.sh"
      # shellcheck disable=SC2086
      sdk_main remove $spec
      ;;
    ai)
      # shellcheck source=../../../nos-ai/lib/ai.sh
      source "$NOS_AI_LIB/ai.sh"
      ai_main remove "$spec"
      ;;
    script)
      nos_warn "$id a été installé par script ; désinstallation manuelle requise (voir docs/handbook/tools.md)."
      return 1
      ;;
    *) nos_die "Méthode inconnue : $method" ;;
  esac
  nos_ok "$id désinstallé."
}

cmd_remove() {
  [ $# -gt 0 ] || nos_die "Usage : nos remove <outil>..."
  local rc=0 tool
  for tool in "$@"; do
    remove_one "$tool" || rc=1
  done
  return $rc
}
