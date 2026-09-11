#!/usr/bin/env bash
# N-OS AI Hub — installation et gestion des assistants IA
# Copyright (C) 2026 ICONEDOR — Burkina Faso
# SPDX-License-Identifier: GPL-3.0-or-later

# id | nom | exécutable | méthode | spec
AI_TOOLS=(
  "claude|Claude Code (Anthropic)|claude|npm|@anthropic-ai/claude-code"
  "gemini|Gemini CLI (Google)|gemini|npm|@google/gemini-cli"
  "copilot|GitHub Copilot CLI|copilot|npm|@github/copilot"
  "opencode|OpenCode|opencode|npm|opencode-ai"
  "aider|Aider|aider|pipx|aider-chat"
  "ollama|Ollama (modèles locaux)|ollama|script|https://ollama.com/install.sh"
  "continue|Continue (extension VS Code)|code|vscode|Continue.continue"
)

ai_lookup() {
  local id="$1" entry
  for entry in "${AI_TOOLS[@]}"; do
    [ "${entry%%|*}" = "$id" ] && { printf '%s' "$entry"; return 0; }
  done
  return 1
}

ai_field() { printf '%s' "$1" | cut -d'|' -f"$2"; }

ai_ensure_npm_user_prefix() {
  nos_has npm || nos_die "npm est requis : nos sdk install node lts"
  local prefix
  prefix="$(npm config get prefix 2>/dev/null | tr -d '\r' || true)"
  if [ "$prefix" = "/usr" ] || [ "$prefix" = "/usr/local" ]; then
    nos_info "Configuration d'un préfixe npm utilisateur (~/.nos/npm-global)"
    mkdir -p "$NOS_HOME/npm-global"
    nos_run npm config set prefix "$NOS_HOME/npm-global"
    nos_ensure_line 'export PATH="$HOME/.nos/npm-global/bin:$PATH"' "$NOS_ENV_FILE"
    export PATH="$NOS_HOME/npm-global/bin:$PATH"
  fi
}

ai_install() {
  local id="$1" entry
  entry="$(ai_lookup "$id")" || nos_die "Assistant inconnu : $id (nos ai list)"
  local name exe method spec
  name="$(ai_field "$entry" 2)"; exe="$(ai_field "$entry" 3)"; method="$(ai_field "$entry" 4)"; spec="$(ai_field "$entry" 5)"
  nos_title "Installation : $name"
  case "$method" in
    npm)
      ai_ensure_npm_user_prefix
      nos_run npm install -g "$spec"
      ;;
    pipx)
      nos_has pipx || nos_apt_install pipx
      nos_run pipx install "$spec"
      nos_run pipx ensurepath
      ;;
    script)
      nos_has curl || nos_apt_install curl
      if [ "$NOS_DRY_RUN" = 1 ]; then
        nos_run "curl -fsSL $spec | sh"
      else
        curl -fsSL "$spec" | sh
      fi
      ;;
    vscode)
      nos_has code || nos_die "VS Code est requis : nos install vscode"
      nos_run code --install-extension "$spec"
      ;;
  esac
  nos_ok "$name installé ($exe)."
  ai_post_install_hint "$id"
}

ai_post_install_hint() {
  case "$1" in
    claude)  nos_info "Première utilisation : claude  (connexion au compte Anthropic)" ;;
    gemini)  nos_info "Première utilisation : gemini  (connexion au compte Google)" ;;
    ollama)  nos_info "Télécharger un modèle : ollama pull llama3.2  puis  ollama run llama3.2" ;;
    aider)   nos_info "Définissez une clé API (ANTHROPIC_API_KEY, OPENAI_API_KEY…) puis lancez : aider" ;;
    copilot) nos_info "Première utilisation : copilot  (connexion GitHub)" ;;
  esac
}

ai_remove() {
  local id="$1" entry
  entry="$(ai_lookup "$id")" || nos_die "Assistant inconnu : $id"
  local name method spec
  name="$(ai_field "$entry" 2)"; method="$(ai_field "$entry" 4)"; spec="$(ai_field "$entry" 5)"
  nos_title "Désinstallation : $name"
  case "$method" in
    npm)    nos_run npm uninstall -g "$spec" ;;
    pipx)   nos_run pipx uninstall "$spec" ;;
    vscode) nos_run code --uninstall-extension "$spec" ;;
    script)
      if [ "$id" = "ollama" ]; then
        nos_sudo systemctl disable --now ollama 2>/dev/null || true
        nos_sudo rm -f /usr/local/bin/ollama /etc/systemd/system/ollama.service
        nos_sudo rm -rf /usr/share/ollama
      fi
      ;;
  esac
  nos_ok "$name désinstallé."
}

ai_status_one() {
  local entry="$1" id name exe
  id="$(ai_field "$entry" 1)"; name="$(ai_field "$entry" 2)"; exe="$(ai_field "$entry" 3)"
  local state="${C_DIM}non installé${C_RESET}"
  if [ "$id" = "continue" ]; then
    nos_has code && code --list-extensions 2>/dev/null | grep -qi '^Continue.continue$' && state="${C_GREEN}installé${C_RESET}"
  elif nos_has "$exe"; then
    state="${C_GREEN}installé${C_RESET} $(nos_tool_version "$exe" 2>/dev/null | cut -c1-40)"
  fi
  printf '  %-10s %-32s %s\n' "$id" "$name" "$state"
}

ai_list() {
  nos_title "Assistants IA"
  local entry
  for entry in "${AI_TOOLS[@]}"; do ai_status_one "$entry"; done
  printf '\n'
}

ai_update_all() {
  local entry id exe method spec
  for entry in "${AI_TOOLS[@]}"; do
    id="$(ai_field "$entry" 1)"; exe="$(ai_field "$entry" 3)"; method="$(ai_field "$entry" 4)"; spec="$(ai_field "$entry" 5)"
    case "$method" in
      npm)  nos_has "$exe" && nos_run npm update -g "$spec" ;;
      pipx) nos_has "$exe" && nos_run pipx upgrade "$spec" ;;
      script) [ "$id" = "ollama" ] && nos_has ollama && { [ "$NOS_DRY_RUN" = 1 ] && nos_run "curl -fsSL $spec | sh" || curl -fsSL "$spec" | sh; } ;;
      vscode) nos_has code && nos_run code --install-extension "$spec" --force ;;
    esac
  done
  return 0
}

ai_usage() {
  cat <<EOF
Usage : nos ai <commande> [assistant]

Commandes :
  list                    État des assistants IA
  install <assistant>...  Installer (claude, gemini, copilot, opencode, aider, ollama, continue)
  remove <assistant>...   Désinstaller
  status [assistant]      Alias de list
  update                  Mettre à jour tous les assistants installés
EOF
}

ai_main() {
  local action="${1:-list}"
  [ $# -gt 0 ] && shift
  case "$action" in
    list|status) ai_list ;;
    install|add)
      [ $# -gt 0 ] || nos_die "Usage : nos ai install <assistant>..."
      local id; for id in "$@"; do ai_install "$id"; done ;;
    remove|rm)
      [ $# -gt 0 ] || nos_die "Usage : nos ai remove <assistant>..."
      local id; for id in "$@"; do ai_remove "$id"; done ;;
    update|upgrade) ai_update_all; nos_ok "Assistants IA à jour." ;;
    -h|--help|help) ai_usage ;;
    *) nos_err "Commande ai inconnue : $action"; ai_usage; return 2 ;;
  esac
}
