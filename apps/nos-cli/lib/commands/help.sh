#!/usr/bin/env bash
# nos help
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_help() {
  nos_banner
  cat <<EOF
${C_BOLD}Usage :${C_RESET} nos <commande> [options]

${C_BOLD}Commandes :${C_RESET}
  doctor [--repair] [--json] [--export FICHIER] [--check ID]
                       Diagnostic de l'environnement de développement
  install <outil>...   Installer un outil du catalogue (nos install --list)
  remove <outil>...    Désinstaller un outil du catalogue
  update [--system] [--sdk] [--ai]
                       Mettre à jour le système et les outils N-OS
  repair               Réparer l'environnement (alias de doctor --repair)
  sdk <list|install|use|remove|current|env> [sdk] [version]
                       Gérer plusieurs versions de Flutter, Java, Node.js, Android SDK
  ai <list|install|remove|status> [assistant]
                       Gérer les assistants IA (Claude Code, Gemini CLI, Ollama, Aider…)
  profile <list|show|apply> [profil]
                       Profils d'usage : dev, bureautique, education, administration, all
  info                 Informations sur le système et les outils installés
  config <get|set|list> [clé] [valeur]
                       Configuration de la CLI
  version              Afficher la version de N-OS
  help                 Cette aide

${C_BOLD}Exemples :${C_RESET}
  nos doctor
  nos doctor --repair
  nos doctor --json > rapport.json
  nos install flutter android-studio docker
  nos sdk install flutter 3.24.5
  nos sdk use java 17
  nos ai install claude
  nos profile apply bureautique

${C_BOLD}Variables :${C_RESET}
  NOS_DRY_RUN=1        Afficher les commandes sans les exécuter
  NO_COLOR=1           Désactiver les couleurs

Documentation : https://github.com/princebilogocode/naabiga-os
EOF
}
