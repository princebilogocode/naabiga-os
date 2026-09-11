#!/usr/bin/env bash
# nos profile, profils d'usage : dev, bureautique, education, administration
# Un profil = outils du catalogue + paquets APT + script d'optimisation (scripts/profiles/<profil>.sh)
# SPDX-License-Identifier: GPL-3.0-or-later

NOS_PROFILES_DIR="${NOS_PROFILES_DIR:-$NOS_SHARE/profiles}"
NOS_PROFILE_SCRIPTS="${NOS_PROFILE_SCRIPTS:-$NOS_SCRIPTS/profiles}"

profile_file() { printf '%s/%s.profile' "$NOS_PROFILES_DIR" "$1"; }

profile_exists() { [ -f "$(profile_file "$1")" ]; }

# Lit une clé du profil (name, description, tools, apt, flatpak, script)
profile_get() {
  local profile="$1" key="$2"
  grep -E "^${key}=" "$(profile_file "$profile")" | cut -d= -f2- | tr -d '\r'
}

profile_list() {
  nos_title "Profils N-OS"
  local f id active
  active="$(nos_config_get profiles "")"
  for f in "$NOS_PROFILES_DIR"/*.profile; do
    [ -f "$f" ] || continue
    id="$(basename "$f" .profile)"
    local mark="  "
    case ",$active," in *",$id,"*) mark="${C_GREEN}✔${C_RESET} " ;; esac
    printf '  %s%-16s %s\n' "$mark" "$id" "$(profile_get "$id" description)"
  done
  printf '\n%sUsage :%s nos profile apply <profil> [--no-optimize]\n\n' "$C_BOLD" "$C_RESET"
}

profile_show() {
  local id="$1"
  profile_exists "$id" || nos_die "Profil inconnu : $id (nos profile list)"
  nos_title "$(profile_get "$id" name) : $(profile_get "$id" description)"
  printf '%sOutils du catalogue :%s %s\n' "$C_BOLD" "$C_RESET" "$(profile_get "$id" tools)"
  printf '%sPaquets APT :%s %s\n' "$C_BOLD" "$C_RESET" "$(profile_get "$id" apt)"
  printf '%sFlatpak :%s %s\n' "$C_BOLD" "$C_RESET" "$(profile_get "$id" flatpak)"
  printf '%sOptimisations :%s %s\n\n' "$C_BOLD" "$C_RESET" "$(profile_get "$id" optimizations)"
}

profile_apply() {
  local id="$1" optimize="${2:-1}"
  profile_exists "$id" || nos_die "Profil inconnu : $id (nos profile list)"
  nos_title "Application du profil : $(profile_get "$id" name)"

  local tools apt_pkgs flatpaks
  tools="$(profile_get "$id" tools)"
  apt_pkgs="$(profile_get "$id" apt)"
  flatpaks="$(profile_get "$id" flatpak)"

  if [ -n "$apt_pkgs" ] && nos_has apt-get; then
    nos_info "Paquets APT : $apt_pkgs"
    nos_sudo apt-get update
    # shellcheck disable=SC2086
    nos_apt_install $apt_pkgs
  elif [ -n "$apt_pkgs" ]; then
    nos_warn "apt-get introuvable : paquets APT ignorés ($apt_pkgs)"
  fi

  if [ -n "$flatpaks" ]; then
    nos_has flatpak || nos_apt_install flatpak
    nos_run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    local ref
    for ref in $flatpaks; do
      nos_run flatpak install -y --noninteractive flathub "$ref"
    done
  fi

  if [ -n "$tools" ]; then
    # shellcheck source=./install.sh
    source "$NOS_LIB/commands/install.sh"
    local tool
    for tool in $tools; do
      install_one "$tool" || nos_warn "Outil non installé : $tool"
    done
  fi

  if [ "$optimize" = 1 ] && [ -f "$NOS_PROFILE_SCRIPTS/$id.sh" ]; then
    nos_info "Optimisations : $NOS_PROFILE_SCRIPTS/$id.sh"
    nos_sudo bash "$NOS_PROFILE_SCRIPTS/$id.sh"
  fi

  local active
  active="$(nos_config_get profiles "")"
  case ",$active," in
    *",$id,"*) ;;
    *) nos_config_set profiles "${active:+$active,}$id" ;;
  esac
  nos_ok "Profil « $id » appliqué."
}

profile_usage() {
  cat <<EOF
Usage : nos profile <commande> [profil]

Commandes :
  list                          Profils disponibles (✔ = appliqué)
  show <profil>                 Contenu d'un profil
  apply <profil> [--no-optimize]  Installer les outils et appliquer les optimisations

Profils : dev (développement), bureautique (travail de bureau), education (enseignement supérieur),
          administration (administration publique et entreprise), all (tous)
EOF
}

cmd_profile() {
  local action="${1:-list}"
  [ $# -gt 0 ] && shift
  case "$action" in
    list|ls) profile_list ;;
    show|info)
      [ -n "${1:-}" ] || nos_die "Usage : nos profile show <profil>"
      profile_show "$1" ;;
    apply|install)
      [ -n "${1:-}" ] || nos_die "Usage : nos profile apply <profil>"
      local id="$1" optimize=1
      [ "${2:-}" = "--no-optimize" ] && optimize=0
      if [ "$id" = "all" ]; then
        local p
        for p in dev bureautique education administration; do profile_apply "$p" "$optimize"; done
      else
        profile_apply "$id" "$optimize"
      fi ;;
    -h|--help|help) profile_usage ;;
    *) nos_err "Commande profile inconnue : $action"; profile_usage; return 2 ;;
  esac
}
