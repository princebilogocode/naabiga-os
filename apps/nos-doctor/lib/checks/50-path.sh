#!/usr/bin/env bash
# Vérification : PATH (dossiers N-OS et outils attendus)
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register path "PATH" "Environnement"

doctor_path_has() {
  case ":$PATH:" in *":$1:"*) return 0 ;; *) return 1 ;; esac
}

check_path() {
  local missing=() expected=()
  expected+=("$HOME/.local/bin")
  [ -d "$NOS_SDK_DIR/flutter/current/bin" ] && expected+=("$NOS_SDK_DIR/flutter/current/bin")
  [ -d "$NOS_SDK_DIR/node/current/bin" ] && expected+=("$NOS_SDK_DIR/node/current/bin")
  [ -d "$NOS_SDK_DIR/android/current/platform-tools" ] && expected+=("$NOS_SDK_DIR/android/current/platform-tools")
  [ -d "$HOME/.pub-cache/bin" ] && expected+=("$HOME/.pub-cache/bin")
  [ -d "$HOME/.cargo/bin" ] && expected+=("$HOME/.cargo/bin")
  local dir
  for dir in "${expected[@]}"; do
    doctor_path_has "$dir" || missing+=("$dir")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    doctor_result warn "dossiers absents du PATH : ${missing[*]}" "source ~/.nos/env.sh (ou reconnectez-vous) : nos doctor --repair"
    return
  fi
  local n
  n="$(printf '%s' "$PATH" | tr ':' '\n' | grep -c . || true)"
  doctor_result ok "$n entrées, dossiers N-OS présents"
}

repair_path() {
  mkdir -p "$HOME/.local/bin"
  nos_ensure_line 'export PATH="$HOME/.local/bin:$PATH"' "$NOS_ENV_FILE"
  [ -d "$HOME/.pub-cache/bin" ] && nos_ensure_line 'export PATH="$HOME/.pub-cache/bin:$PATH"' "$NOS_ENV_FILE"
  [ -d "$HOME/.cargo/bin" ] && nos_ensure_line 'export PATH="$HOME/.cargo/bin:$PATH"' "$NOS_ENV_FILE"
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] && nos_ensure_line '[ -f "$HOME/.nos/env.sh" ] && . "$HOME/.nos/env.sh"' "$rc"
  done
  # shellcheck source=/dev/null
  [ -f "$NOS_ENV_FILE" ] && . "$NOS_ENV_FILE"
  return 0
}
