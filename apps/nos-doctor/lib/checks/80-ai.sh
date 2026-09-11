#!/usr/bin/env bash
# Vérification : assistants IA
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register ai "Assistants IA" "IA"

check_ai() {
  local present=() tool
  for tool in claude gemini ollama aider opencode copilot; do
    nos_has "$tool" && present+=("$tool")
  done
  if [ "${#present[@]}" -eq 0 ]; then
    doctor_result warn "aucun assistant IA installé" "nos ai install claude (ou gemini, ollama, aider, opencode)"
    return
  fi
  doctor_result ok "${present[*]}"
}
