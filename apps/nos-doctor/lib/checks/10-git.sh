#!/usr/bin/env bash
# Vérification : Git
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register git "Git" "Base"

check_git() {
  if ! nos_has git; then
    doctor_result fail "git introuvable" "nos install git"
    return
  fi
  local v name email
  v="$(git --version 2>/dev/null | awk '{print $3}')"
  name="$(git config --global user.name 2>/dev/null || true)"
  email="$(git config --global user.email 2>/dev/null || true)"
  if [ -z "$name" ] || [ -z "$email" ]; then
    doctor_result warn "git $v — identité non configurée" "git config --global user.name \"Nom\" && git config --global user.email \"vous@exemple.com\""
  else
    doctor_result ok "git $v ($name <$email>)"
  fi
}

repair_git() {
  nos_has git && return 0
  nos_apt_install git
}
