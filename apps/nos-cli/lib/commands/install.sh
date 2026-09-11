#!/usr/bin/env bash
# nos install — installe des outils depuis le catalogue N-OS
# SPDX-License-Identifier: GPL-3.0-or-later

install_list() {
  nos_title "Catalogue N-OS ($(nos_catalog_list | wc -l | tr -d ' ') outils)"
  local current_cat=""
  nos_catalog_list | sort -t$'\t' -k2,2 -k1,1 | while IFS=$'\t' read -r id cat desc method _; do
    if [ "$cat" != "$current_cat" ]; then
      printf '\n%s%s%s\n' "$C_GOLD" "$cat" "$C_RESET"
      current_cat="$cat"
    fi
    local mark="  "
    install_is_present "$id" && mark="${C_GREEN}✔${C_RESET} "
    printf '  %s%-18s %s %s(%s)%s\n' "$mark" "$id" "$desc" "$C_DIM" "$method" "$C_RESET"
  done
  printf '\n'
}

# Heuristique : l'outil est-il déjà présent ?
install_is_present() {
  local id="$1" entry
  entry="$(nos_catalog_lookup "$id" 2>/dev/null)" || return 1
  local method spec
  method="$(printf '%s' "$entry" | cut -f4)"
  spec="$(printf '%s' "$entry" | cut -f5)"
  case "$method" in
    apt)     nos_has dpkg && dpkg -s "${spec%% *}" >/dev/null 2>&1 ;;
    flatpak) nos_has flatpak && flatpak info "$spec" >/dev/null 2>&1 ;;
    npm)     nos_has "$(printf '%s' "$entry" | cut -f6)" ;;
    pipx)    nos_has "$(printf '%s' "$entry" | cut -f6)" ;;
    script|sdk|ai) nos_has "$(printf '%s' "$entry" | cut -f6)" ;;
    *) return 1 ;;
  esac
}

install_one() {
  local id="$1" entry
  if ! entry="$(nos_catalog_lookup "$id")"; then
    nos_err "Outil inconnu : $id (voir 'nos install --list')"
    return 1
  fi
  local desc method spec
  desc="$(printf '%s' "$entry" | cut -f3)"
  method="$(printf '%s' "$entry" | cut -f4)"
  spec="$(printf '%s' "$entry" | cut -f5)"

  nos_title "Installation : $id — $desc"
  case "$method" in
    apt)
      # shellcheck disable=SC2086
      nos_apt_install $spec
      ;;
    flatpak)
      nos_has flatpak || nos_apt_install flatpak
      nos_run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      nos_run flatpak install -y flathub "$spec"
      ;;
    npm)
      nos_has npm || nos_die "npm est requis : nos sdk install node"
      nos_run npm install -g "$spec"
      ;;
    pipx)
      nos_has pipx || nos_apt_install pipx
      nos_run pipx install "$spec"
      ;;
    script)
      local script="$NOS_SCRIPTS/dev-tools/$spec"
      [ -f "$script" ] || nos_die "Script introuvable : $script"
      nos_run bash "$script"
      ;;
    sdk)
      # shellcheck source=../../../nos-sdk/lib/sdk.sh
      source "$NOS_SDK_LIB/sdk.sh"
      # shellcheck disable=SC2086
      sdk_main install $spec
      ;;
    ai)
      # shellcheck source=../../../nos-ai/lib/ai.sh
      source "$NOS_AI_LIB/ai.sh"
      ai_main install "$spec"
      ;;
    *)
      nos_die "Méthode d'installation inconnue : $method"
      ;;
  esac
  nos_ok "$id installé."
}

cmd_install() {
  case "${1:-}" in
    ""|-l|--list|list) install_list; return 0 ;;
    -h|--help) printf 'Usage : nos install <outil>... | nos install --list\n'; return 0 ;;
  esac
  local rc=0 tool
  for tool in "$@"; do
    install_one "$tool" || rc=1
  done
  return $rc
}
