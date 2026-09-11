#!/usr/bin/env bash
# Vérification : profil Administration (antivirus, sauvegardes, durcissement)
# Bloquant seulement si le profil administration a été appliqué.
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register administration "Profil Administration" "Profils"

check_administration() {
  case ",$(nos_config_get profiles ""),"  in
    *",administration,"*) ;;
    *) doctor_result ok "profil non appliqué (nos profile apply administration)"; return ;;
  esac
  local problems=()
  nos_has clamscan || problems+=("ClamAV absent")
  nos_has deja-dup || problems+=("Déjà Dup absent")
  nos_has remmina || problems+=("Remmina absent")
  nos_has realm || problems+=("intégration AD (realmd) absente")
  if nos_is_linux; then
    [ -f /etc/sudoers.d/90-naabiga-admin ] || problems+=("durcissement sudo non appliqué")
    [ -f /etc/dconf/db/local.d/locks/naabiga-administration ] || problems+=("politiques dconf non verrouillées")
    if nos_has systemctl && ! systemctl is-enabled --quiet clamav-freshclam 2>/dev/null; then
      problems+=("mises à jour ClamAV inactives")
    fi
  fi
  if [ "${#problems[@]}" -gt 0 ]; then
    doctor_result fail "${problems[*]}" "nos profile apply administration"
    return
  fi
  doctor_result ok "antivirus, sauvegardes, accès distant, durcissement en place"
}

repair_administration() {
  # shellcheck source=../../../nos-cli/lib/commands/profile.sh
  source "$NOS_LIB/commands/profile.sh"
  profile_apply administration 1
}
