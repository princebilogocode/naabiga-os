#!/usr/bin/env bash
# Vérification : PHP et Composer
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register php "PHP / Composer" "Langages"

check_php() {
  if ! nos_has php; then
    doctor_result warn "php introuvable (optionnel)" "nos install php composer"
    return
  fi
  local v
  v="$(php -r 'echo PHP_VERSION;' 2>/dev/null | tr -d '\r')"
  if ! nos_has composer; then
    doctor_result warn "PHP $v — Composer absent" "nos install composer"
    return
  fi
  local missing=() ext
  for ext in mbstring xml curl zip; do
    php -m 2>/dev/null | grep -qi "^$ext$" || missing+=("$ext")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    doctor_result warn "PHP $v — extensions manquantes : ${missing[*]}" "nos install php"
    return
  fi
  doctor_result ok "PHP $v, Composer $(composer --version 2>/dev/null | awk '{print $3}' | tr -d '\r')"
}

repair_php() {
  nos_apt_install php-cli php-mbstring php-xml php-curl php-zip php-sqlite3 composer
}
