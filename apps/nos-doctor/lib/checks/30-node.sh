#!/usr/bin/env bash
# Vérification : Node.js
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register node "Node.js" "Web"

check_node() {
  if ! nos_has node; then
    doctor_result fail "node introuvable" "nos sdk install node lts"
    return
  fi
  local v major
  v="$(node --version 2>/dev/null | tr -d '\r')"
  major="${v#v}"; major="${major%%.*}"
  if ! nos_has npm; then
    doctor_result warn "Node $v — npm absent" "nos sdk install node lts"
    return
  fi
  if [ "${major:-0}" -lt 20 ]; then
    doctor_result warn "Node $v — version < 20 LTS" "nos sdk install node lts && nos sdk use node lts"
    return
  fi
  local npm_prefix
  npm_prefix="$(npm config get prefix 2>/dev/null | tr -d '\r' || true)"
  if nos_is_linux && [ "$npm_prefix" = "/usr" ] || [ "$npm_prefix" = "/usr/local" ]; then
    doctor_result warn "Node $v, npm $(npm --version 2>/dev/null) — 'npm -g' nécessite sudo (prefix $npm_prefix)" "npm config set prefix ~/.nos/npm-global && ajouter ~/.nos/npm-global/bin au PATH"
    return
  fi
  doctor_result ok "Node $v, npm $(npm --version 2>/dev/null | tr -d '\r')"
}

repair_node() {
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  if ! nos_has node; then
    sdk_main install node lts && sdk_main use node lts && return 0
  fi
  local npm_prefix
  npm_prefix="$(npm config get prefix 2>/dev/null | tr -d '\r' || true)"
  if [ "$npm_prefix" = "/usr" ] || [ "$npm_prefix" = "/usr/local" ]; then
    mkdir -p "$NOS_HOME/npm-global"
    nos_run npm config set prefix "$NOS_HOME/npm-global"
    nos_ensure_line 'export PATH="$HOME/.nos/npm-global/bin:$PATH"' "$NOS_ENV_FILE"
  fi
}
