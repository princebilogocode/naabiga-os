#!/usr/bin/env bash
# nos info — informations système
# SPDX-License-Identifier: GPL-3.0-or-later

info_row() { printf '  %s%-16s%s %s\n' "$C_BOLD" "$1" "$C_RESET" "$2"; }

info_tool() {
  local label="$1" tool="$2" flag="${3:---version}"
  if nos_has "$tool"; then
    info_row "$label" "$(nos_tool_version "$tool" "$flag")"
  else
    info_row "$label" "${C_DIM}non installé${C_RESET}"
  fi
}

cmd_info() {
  nos_banner
  nos_title "Système"
  info_row "Distribution" "$(nos_os_pretty)"
  info_row "N-OS" "$(nos_version)"
  info_row "Noyau" "$(uname -r)"
  info_row "Architecture" "$(uname -m)"
  info_row "Hôte" "$(hostname 2>/dev/null || uname -n)"
  info_row "Utilisateur" "${USER:-$(id -un)}"
  info_row "Shell" "${SHELL:-inconnu}"
  if nos_is_linux && [ -r /proc/meminfo ]; then
    local mem_kb
    mem_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    info_row "Mémoire" "$(( mem_kb / 1024 )) Mo"
  fi
  if nos_has nproc; then info_row "CPU" "$(nproc) cœurs"; fi
  if nos_has df; then
    info_row "Disque /" "$(df -h / 2>/dev/null | awk 'NR==2 {print $4 " libres / " $2}')"
  fi

  nos_title "Outils de développement"
  info_tool "Git" git
  info_tool "Java" java -version
  info_tool "Flutter" flutter
  info_tool "Dart" dart
  info_tool "Node.js" node
  info_tool "npm" npm
  info_tool "Python" python3
  info_tool "Docker" docker
  info_tool "adb" adb
  info_tool "Go" go version
  info_tool "Rust" rustc
  info_tool "PHP" php
  info_tool "VS Code" code

  nos_title "Assistants IA"
  info_tool "Claude Code" claude
  info_tool "Gemini CLI" gemini
  info_tool "Ollama" ollama
  info_tool "Aider" aider
  info_tool "OpenCode" opencode
  printf '\n'
}
