#!/usr/bin/env bash
# Vérification : Visual Studio Code
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register vscode "Visual Studio Code" "IDE"

check_vscode() {
  if ! nos_has code; then
    doctor_result warn "code introuvable" "nos install vscode"
    return
  fi
  local v
  v="$(code --version 2>/dev/null | head -n 1 | tr -d '\r')"
  doctor_result ok "VS Code $v"
}

repair_vscode() {
  nos_run bash "$NOS_SCRIPTS/dev-tools/install-vscode.sh"
}
