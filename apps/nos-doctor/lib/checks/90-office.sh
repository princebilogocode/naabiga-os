#!/usr/bin/env bash
# Vérification : bureautique (LibreOffice, français, impression) : pertinente pour les profils
# bureautique, education et administration ; simple information sinon.
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register office "Bureautique (LibreOffice, impression)" "Bureautique"

check_office() {
  local profiles
  profiles="$(nos_config_get profiles "")"
  local office_profile=0
  case ",$profiles," in *",bureautique,"*|*",education,"*|*",administration,"*) office_profile=1 ;; esac

  if ! nos_has libreoffice && ! nos_has soffice; then
    if [ "$office_profile" = 1 ]; then
      doctor_result fail "LibreOffice absent" "nos install libreoffice"
    else
      doctor_result warn "LibreOffice absent (profil développement)" "nos profile apply bureautique"
    fi
    return
  fi
  local problems=()
  if nos_is_linux && nos_has dpkg; then
    dpkg -s libreoffice-l10n-fr >/dev/null 2>&1 || problems+=("interface française (libreoffice-l10n-fr)")
    dpkg -s hunspell-fr >/dev/null 2>&1 || dpkg -s hunspell-fr-comprehensive >/dev/null 2>&1 || problems+=("dictionnaire français (hunspell-fr)")
    dpkg -s fonts-crosextra-carlito >/dev/null 2>&1 || problems+=("polices compatibles Office (fonts-crosextra-carlito)")
    if [ "$office_profile" = 1 ] && nos_has systemctl && ! systemctl is-active --quiet cups 2>/dev/null; then
      problems+=("service d'impression CUPS inactif")
    fi
  fi
  if [ "${#problems[@]}" -gt 0 ]; then
    doctor_result warn "manque : ${problems[*]}" "nos profile apply bureautique"
    return
  fi
  doctor_result ok "LibreOffice $(soffice --version 2>/dev/null | awk '{print $2}' || true) en français, impression prête"
}

repair_office() {
  nos_apt_install libreoffice libreoffice-l10n-fr hunspell-fr-comprehensive fonts-crosextra-carlito fonts-crosextra-caladea cups
  nos_has systemctl && nos_sudo systemctl enable --now cups || true
}
