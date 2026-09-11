#!/usr/bin/env bash
# Vérification : profil Enseignement supérieur (LaTeX, Jupyter, R, Veyon)
# Bloquant seulement si le profil education a été appliqué.
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register education "Profil Enseignement supérieur" "Profils"

doctor_profile_applied() {
  case ",$(nos_config_get profiles ""),"  in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

check_education() {
  if ! doctor_profile_applied education; then
    doctor_result ok "profil non appliqué (nos profile apply education)"
    return
  fi
  local missing=()
  nos_has pdflatex || missing+=("LaTeX")
  nos_has jupyter-lab || nos_has jupyter || missing+=("Jupyter")
  nos_has R || missing+=("R")
  nos_has octave || missing+=("Octave")
  nos_has xournalpp || missing+=("Xournal++")
  if [ "${#missing[@]}" -gt 0 ]; then
    doctor_result fail "manque : ${missing[*]}" "nos profile apply education"
    return
  fi
  local classroom
  classroom="$(nos_config_get classroom 0)"
  if [ "$classroom" = "1" ] && ! id etudiant >/dev/null 2>&1; then
    doctor_result warn "mode salle de TP demandé mais compte 'etudiant' absent" "sudo bash $NOS_SCRIPTS/profiles/education.sh"
    return
  fi
  doctor_result ok "LaTeX, Jupyter, R, Octave, Xournal++ présents$([ "$classroom" = 1 ] && printf ' : salle de TP active')"
}

repair_education() {
  # shellcheck source=../../../nos-cli/lib/commands/profile.sh
  source "$NOS_LIB/commands/profile.sh"
  profile_apply education 1
}
