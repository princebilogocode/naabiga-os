#!/usr/bin/env bash
# nos welcome : assistant de premier démarrage : profil, IDE, assistants IA, diagnostic
# Interactif (whiptail) ou non interactif (--profile, --ide, --ai, --yes)
# SPDX-License-Identifier: GPL-3.0-or-later

NOS_WELCOME_DONE="${NOS_WELCOME_DONE:-$NOS_HOME/welcome.done}"

welcome_usage() {
  cat <<EOF
Usage : nos welcome [options]

Sans option : assistant interactif (une seule fois ; relancer avec --force).

Options :
  --profile <p>[,<p>]   Profils à appliquer : dev, bureautique, education, administration
  --ide <id>[,<id>]     IDE à installer : vscode, android-studio
  --ai <id>[,<id>]      Assistants IA : claude, gemini, ollama, aider, opencode, continue, copilot
  --no-doctor           Ne pas lancer nos doctor à la fin
  --yes, -y             Mode non interactif (utilise les options ci-dessus, profil dev par défaut)
  --force               Relancer même si l'assistant a déjà été exécuté
  --reset               Oublier l'exécution précédente et quitter
  -h, --help            Cette aide
EOF
}

welcome_has_tui() { [ -t 0 ] && [ -t 1 ] && nos_has whiptail; }

# Liste à cocher : welcome_checklist "Titre" "Texte" "tag|libellé|on/off" ...  → tags séparés par des espaces
welcome_checklist() {
  local title="$1" text="$2"; shift 2
  local args=() item
  for item in "$@"; do
    IFS='|' read -r tag label state <<< "$item"
    args+=("$tag" "$label" "$state")
  done
  whiptail --title "$title" --separate-output --checklist "$text" 20 78 10 "${args[@]}" 3>&1 1>&2 2>&3 | tr '\n' ' '
}

welcome_ask_plain() {
  # Repli sans whiptail : question texte, réponse séparée par des espaces
  local text="$1" default="$2" answer
  printf '%s [%s] : ' "$text" "$default"
  read -r answer
  printf '%s' "${answer:-$default}"
}

welcome_run() {
  local profiles="$1" ides="$2" ais="$3" do_doctor="$4"
  # shellcheck source=./profile.sh
  source "$NOS_LIB/commands/profile.sh"
  local wp
  for wp in ${profiles//,/ }; do
    profile_apply "$wp" 1 || nos_warn "Profil non appliqué : $wp"
  done
  if [ -n "$ides" ]; then
    # shellcheck source=./install.sh
    source "$NOS_LIB/commands/install.sh"
    local ide
    for ide in ${ides//,/ }; do install_one "$ide" || nos_warn "IDE non installé : $ide"; done
  fi
  if [ -n "$ais" ]; then
    # shellcheck source=../../../nos-ai/lib/ai.sh
    source "$NOS_AI_LIB/ai.sh"
    local a
    for a in ${ais//,/ }; do ai_install "$a" || nos_warn "Assistant non installé : $a"; done
  fi
  mkdir -p "$(dirname "$NOS_WELCOME_DONE")"
  {
    printf 'date=%s\nprofiles=%s\nides=%s\nais=%s\n' "$(date '+%Y-%m-%d %H:%M')" "$profiles" "$ides" "$ais"
  } > "$NOS_WELCOME_DONE"
  if [ "$do_doctor" = 1 ]; then
    # shellcheck source=../../../nos-doctor/lib/doctor.sh
    source "$NOS_DOCTOR_LIB/doctor.sh"
    doctor_main --no-fail
  fi
  nos_ok "Bienvenue sur Naabiga OS. Tapez 'nos help' pour découvrir toutes les commandes."
}

cmd_welcome() {
  local profiles="" ides="" ais="" do_doctor=1 yes=0 force=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --profile) profiles="${2:-}"; shift ;;
      --ide) ides="${2:-}"; shift ;;
      --ai) ais="${2:-}"; shift ;;
      --no-doctor) do_doctor=0 ;;
      --yes|-y) yes=1 ;;
      --force) force=1 ;;
      --reset) rm -f "$NOS_WELCOME_DONE"; nos_ok "Assistant réinitialisé."; return 0 ;;
      -h|--help) welcome_usage; return 0 ;;
      *) nos_err "Option inconnue : $1"; welcome_usage; return 2 ;;
    esac
    shift
  done

  if [ -f "$NOS_WELCOME_DONE" ] && [ "$force" = 0 ]; then
    nos_info "L'assistant de bienvenue a déjà été exécuté ($NOS_WELCOME_DONE). Utilisez --force pour le relancer."
    return 0
  fi

  if [ "$yes" = 1 ] || { [ -n "$profiles$ides$ais" ] && ! welcome_has_tui; }; then
    welcome_run "${profiles:-dev}" "$ides" "$ais" "$do_doctor"
    return $?
  fi

  nos_banner
  printf '%sBienvenue sur Naabiga OS%s : le premier système d'\''exploitation burkinabè, pour le Burkina et l'\''Afrique.\n' "$C_BOLD" "$C_RESET"
  printf 'Cet assistant prépare votre poste en quelques questions. Rien n'\''est installé sans votre accord.\n\n'

  if welcome_has_tui; then
    profiles="$(welcome_checklist "Naabiga OS : Profil d'usage" "À quoi servira ce poste ? (Espace pour cocher)" \
      "dev|Développement : Flutter, Android, Web, DevOps, IA|on" \
      "bureautique|Bureautique : LibreOffice, PDF, courriel, impression|off" \
      "education|Enseignement supérieur : LaTeX, Jupyter, R, salle de TP|off" \
      "administration|Administration : poste durci, sauvegardes, AD|off")"
    ides="$(welcome_checklist "Naabiga OS : IDE" "Environnements de développement à installer" \
      "vscode|Visual Studio Code|on" \
      "android-studio|Android Studio (~1 Go)|off")"
    ais="$(welcome_checklist "Naabiga OS : Assistants IA" "Assistants IA à installer (compte requis pour certains)" \
      "claude|Claude Code (Anthropic)|on" \
      "gemini|Gemini CLI (Google)|off" \
      "ollama|Ollama : modèles locaux, hors ligne|off" \
      "aider|Aider|off" \
      "opencode|OpenCode|off" \
      "continue|Continue (extension VS Code)|off" \
      "copilot|GitHub Copilot CLI|off")"
    if whiptail --title "Naabiga OS : Diagnostic" --yesno "Lancer 'nos doctor' à la fin pour vérifier l'installation ?" 10 60; then do_doctor=1; else do_doctor=0; fi
  else
    profiles="$(welcome_ask_plain "Profils (dev bureautique education administration)" "dev")"
    ides="$(welcome_ask_plain "IDE (vscode android-studio, vide pour aucun)" "vscode")"
    ais="$(welcome_ask_plain "Assistants IA (claude gemini ollama aider opencode continue copilot, vide pour aucun)" "claude")"
  fi
  profiles="$(printf '%s' "$profiles" | tr ', ' '  ' | xargs 2>/dev/null || true)"
  ides="$(printf '%s' "$ides" | tr ', ' '  ' | xargs 2>/dev/null || true)"
  ais="$(printf '%s' "$ais" | tr ', ' '  ' | xargs 2>/dev/null || true)"
  [ -n "$profiles" ] || profiles="dev"

  nos_title "Récapitulatif"
  printf '  Profils       : %s\n  IDE           : %s\n  Assistants IA : %s\n  Diagnostic    : %s\n\n' "$profiles" "${ides:-aucun}" "${ais:-aucun}" "$([ "$do_doctor" = 1 ] && echo oui || echo non)"
  local go
  go="$(welcome_ask_plain "Continuer ? (o/n)" "o")"
  case "$go" in o|O|oui|y|Y|yes) ;; *) nos_info "Annulé. Relancez plus tard avec : nos welcome"; return 0 ;; esac
  welcome_run "$profiles" "$ides" "$ais" "$do_doctor"
}
