#!/usr/bin/env bash
# Vérification : Go
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register go "Go" "Langages"

check_go() {
  if ! nos_has go; then
    doctor_result warn "go introuvable (optionnel)" "nos install go"
    return
  fi
  local v
  v="$(go version 2>/dev/null | awk '{print $3}' | tr -d '\r')"
  local in_path=1
  case ":$PATH:" in *":$HOME/go/bin:"*) in_path=1 ;; *) in_path=0 ;; esac
  if [ -d "$HOME/go/bin" ] && [ "$in_path" = 0 ]; then
    doctor_result warn "$v : \$HOME/go/bin absent du PATH" "echo 'export PATH=\"\$HOME/go/bin:\$PATH\"' >> ~/.nos/env.sh"
    return
  fi
  doctor_result ok "$v"
}

repair_go() {
  nos_has go || nos_apt_install golang-go
  [ -d "$HOME/go/bin" ] && nos_ensure_line 'export PATH="$HOME/go/bin:$PATH"' "$NOS_ENV_FILE"
  return 0
}
