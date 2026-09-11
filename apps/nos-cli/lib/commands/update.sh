#!/usr/bin/env bash
# nos update — met à jour le système, les SDK et les assistants IA ; --check compare avec la dernière version N-OS
# SPDX-License-Identifier: GPL-3.0-or-later

NOS_RELEASES_API="${NOS_RELEASES_API:-https://api.github.com/repos/princebilogocode/naabiga-os/releases/latest}"

# Compare deux versions SemVer (pré-versions incluses) : retourne 0 si $1 < $2
update_version_lt() {
  local a="${1#v}" b="${2#v}"
  [ "$a" = "$b" ] && return 1
  # sort -V classe 1.0.0-alpha.1 avant 1.0.0 : on remplace '-' par '~' pour respecter SemVer
  local first
  first="$(printf '%s\n%s\n' "${a//-/\~}" "${b//-/\~}" | sort -V | head -n 1)"
  [ "$first" = "${a//-/\~}" ]
}

update_latest_version() {
  if [ -n "${NOS_LATEST_VERSION:-}" ]; then printf '%s' "$NOS_LATEST_VERSION"; return 0; fi
  nos_has curl || return 1
  curl -fsSL --max-time 10 -H 'Accept: application/vnd.github+json' "$NOS_RELEASES_API" 2>/dev/null \
    | grep -o '"tag_name": *"[^"]*"' | head -n 1 | sed -E 's/.*"v?([^"]+)"$/\1/'
}

update_check() {
  local current latest
  current="$(nos_version)"
  nos_title "Vérification des mises à jour N-OS"
  if ! latest="$(update_latest_version)" || [ -z "$latest" ]; then
    nos_warn "Impossible de joindre le serveur de versions ($NOS_RELEASES_API)."
    printf 'Version installée : %s\n' "$current"
    return 1
  fi
  printf 'Version installée : %s\nDernière version  : %s\n' "$current" "$latest"
  if update_version_lt "$current" "$latest"; then
    nos_info "Une nouvelle version de Naabiga OS est disponible : $latest"
    nos_info "Notes de version : https://github.com/princebilogocode/naabiga-os/releases/tag/v$latest"
    return 10
  fi
  nos_ok "Naabiga OS est à jour."
}

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
  local do_system=0 do_sdk=0 do_ai=0 do_check=0
  if [ $# -eq 0 ]; then do_system=1; do_sdk=1; do_ai=1; do_check=1; fi
  while [ $# -gt 0 ]; do
    case "$1" in
      --system) do_system=1 ;;
      --sdk)    do_sdk=1 ;;
      --ai)     do_ai=1 ;;
      --check)  do_check=1 ;;
      --all)    do_system=1; do_sdk=1; do_ai=1; do_check=1 ;;
      -h|--help) printf 'Usage : nos update [--system] [--sdk] [--ai] [--check] [--all]\n  --check : compare la version installée avec la dernière version publiée (code 10 si une mise à jour existe)\n'; return 0 ;;
      *) nos_die "Option inconnue : $1" ;;
    esac
    shift
  done
  [ "$do_system" = 1 ] && update_system
  [ "$do_sdk" = 1 ] && update_sdk
  [ "$do_ai" = 1 ] && update_ai
  if [ "$do_check" = 1 ]; then
    local rc=0
    update_check || rc=$?
    # --check seul : on propage le code (10 = mise à jour disponible, 1 = réseau)
    if [ "$do_system$do_sdk$do_ai" = "000" ]; then return "$rc"; fi
  fi
  nos_ok "Mise à jour terminée."
}
