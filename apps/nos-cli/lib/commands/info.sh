#!/usr/bin/env bash
# nos info : informations système (texte ou --json pour N-OS Center)
# SPDX-License-Identifier: GPL-3.0-or-later

INFO_TOOLS=(
  "git|Git|git|--version"
  "java|Java|java|-version"
  "flutter|Flutter|flutter|--version"
  "dart|Dart|dart|--version"
  "node|Node.js|node|--version"
  "npm|npm|npm|--version"
  "python|Python|python3|--version"
  "docker|Docker|docker|--version"
  "adb|adb|adb|--version"
  "go|Go|go|version"
  "rust|Rust|rustc|--version"
  "php|PHP|php|--version"
  "vscode|VS Code|code|--version"
)
INFO_AI=(
  "claude|Claude Code|claude|--version"
  "gemini|Gemini CLI|gemini|--version"
  "ollama|Ollama|ollama|--version"
  "aider|Aider|aider|--version"
  "opencode|OpenCode|opencode|--version"
)

info_row() { printf '  %s%-16s%s %s\n' "$C_BOLD" "$1" "$C_RESET" "$2"; }

info_tool_line() {
  local label="$1" tool="$2" flag="$3"
  if nos_has "$tool"; then
    info_row "$label" "$(nos_tool_version "$tool" "$flag")"
  else
    info_row "$label" "${C_DIM}non installé${C_RESET}"
  fi
}

info_mem_mb() {
  if nos_is_linux && [ -r /proc/meminfo ]; then
    awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo
  else
    printf '0'
  fi
}

info_disk_free() {
  nos_has df && df -h / 2>/dev/null | awk 'NR==2 {print $4 " libres / " $2}' || true
}

info_json_tools() {
  local first=1 entry id label tool flag
  for entry in "$@"; do
    IFS='|' read -r id label tool flag <<< "$entry"
    [ "$first" = 1 ] || printf ','
    first=0
    if nos_has "$tool"; then
      printf '\n    {"id": "%s", "label": "%s", "installed": true, "version": "%s"}' "$id" "$(nos_json_escape "$label")" "$(nos_json_escape "$(nos_tool_version "$tool" "$flag")")"
    else
      printf '\n    {"id": "%s", "label": "%s", "installed": false, "version": ""}' "$id" "$(nos_json_escape "$label")"
    fi
  done
}

info_print_json() {
  printf '{\n'
  printf '  "nos_version": "%s",\n' "$(nos_json_escape "$(nos_version)")"
  printf '  "system": "%s",\n' "$(nos_json_escape "$(nos_os_pretty)")"
  printf '  "kernel": "%s",\n' "$(nos_json_escape "$(uname -r)")"
  printf '  "arch": "%s",\n' "$(nos_json_escape "$(uname -m)")"
  printf '  "hostname": "%s",\n' "$(nos_json_escape "$(hostname 2>/dev/null || uname -n)")"
  printf '  "user": "%s",\n' "$(nos_json_escape "${USER:-$(id -un)}")"
  printf '  "memory_mb": %s,\n' "$(info_mem_mb)"
  printf '  "cpus": %s,\n' "$(nos_has nproc && nproc || printf '0')"
  printf '  "disk_root": "%s",\n' "$(nos_json_escape "$(info_disk_free)")"
  printf '  "profiles": "%s",\n' "$(nos_json_escape "$(nos_config_get profiles "")")"
  printf '  "tools": ['; info_json_tools "${INFO_TOOLS[@]}"; printf '\n  ],\n'
  printf '  "ai": ['; info_json_tools "${INFO_AI[@]}"; printf '\n  ]\n'
  printf '}\n'
}

cmd_info() {
  case "${1:-}" in
    --json) info_print_json; return 0 ;;
    -h|--help) printf 'Usage : nos info [--json]\n'; return 0 ;;
  esac
  nos_banner
  nos_title "Système"
  info_row "Distribution" "$(nos_os_pretty)"
  info_row "N-OS" "$(nos_version)"
  info_row "Noyau" "$(uname -r)"
  info_row "Architecture" "$(uname -m)"
  info_row "Hôte" "$(hostname 2>/dev/null || uname -n)"
  info_row "Utilisateur" "${USER:-$(id -un)}"
  info_row "Shell" "${SHELL:-inconnu}"
  local mem
  mem="$(info_mem_mb)"
  [ "$mem" != 0 ] && info_row "Mémoire" "$mem Mo"
  nos_has nproc && info_row "CPU" "$(nproc) cœurs"
  info_row "Disque /" "$(info_disk_free)"
  local profiles
  profiles="$(nos_config_get profiles "")"
  info_row "Profils" "${profiles:-aucun (nos profile apply …)}"

  nos_title "Outils de développement"
  local entry id label tool flag
  for entry in "${INFO_TOOLS[@]}"; do IFS='|' read -r id label tool flag <<< "$entry"; info_tool_line "$label" "$tool" "$flag"; done
  nos_title "Assistants IA"
  for entry in "${INFO_AI[@]}"; do IFS='|' read -r id label tool flag <<< "$entry"; info_tool_line "$label" "$tool" "$flag"; done
  printf '\n'
}
