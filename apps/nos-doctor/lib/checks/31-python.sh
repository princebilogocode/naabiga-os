#!/usr/bin/env bash
# Vérification : Python
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register python "Python 3" "Web"

check_python() {
  local py=""
  if nos_has python3; then py=python3; elif nos_has python; then py=python; fi
  if [ -z "$py" ]; then
    doctor_result fail "python3 introuvable" "nos install python"
    return
  fi
  local v
  v="$("$py" --version 2>&1 | tr -d '\r')"
  case "$v" in
    "Python 3."*) ;;
    *) doctor_result fail "$v — Python 3 requis" "nos install python"; return ;;
  esac
  if ! "$py" -m pip --version >/dev/null 2>&1; then
    doctor_result warn "$v — pip absent" "sudo apt install python3-pip"
    return
  fi
  if ! "$py" -c 'import venv' >/dev/null 2>&1; then
    doctor_result warn "$v — module venv absent" "sudo apt install python3-venv"
    return
  fi
  doctor_result ok "$v, pip $("$py" -m pip --version 2>/dev/null | awk '{print $2}')"
}

repair_python() {
  nos_apt_install python3 python3-pip python3-venv pipx
}
