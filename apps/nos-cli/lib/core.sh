#!/usr/bin/env bash
# core.sh — fonctions communes de la CLI nos
# SPDX-License-Identifier: GPL-3.0-or-later

NOS_NAME="Naabiga OS"
NOS_SHORT="N-OS"
NOS_VERSION_FILE="${NOS_VERSION_FILE:-}"
NOS_DRY_RUN="${NOS_DRY_RUN:-0}"
NOS_NO_COLOR="${NO_COLOR:-}"
NOS_HOME="${NOS_HOME:-$HOME/.nos}"
NOS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nos"
NOS_CONFIG_FILE="$NOS_CONFIG_DIR/config"
NOS_SDK_DIR="${NOS_SDK_DIR:-$NOS_HOME/sdk}"
NOS_ENV_FILE="$NOS_HOME/env.sh"

# --- Couleurs ---------------------------------------------------------------
if [ -t 1 ] && [ -z "$NOS_NO_COLOR" ]; then
  C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
  C_RED=$'\e[31m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_BLUE=$'\e[34m'; C_GOLD=$'\e[33;1m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_GOLD=""
fi
export C_RESET C_BOLD C_DIM C_RED C_GREEN C_YELLOW C_BLUE C_GOLD

# --- Journalisation ----------------------------------------------------------
nos_info()  { printf '%s[i]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
nos_ok()    { printf '%s[✔]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
nos_warn()  { printf '%s[!]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
nos_err()   { printf '%s[✘]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
nos_title() { printf '\n%s%s%s\n' "$C_BOLD" "$*" "$C_RESET"; }
nos_die()   { nos_err "$@"; exit 1; }

# --- Version ------------------------------------------------------------------
nos_version() {
  if [ -n "$NOS_VERSION_FILE" ] && [ -f "$NOS_VERSION_FILE" ]; then
    tr -d '[:space:]' < "$NOS_VERSION_FILE"
  elif [ "${NOS_MODE:-}" = "dev" ] && [ -f "$NOS_ROOT/VERSION" ]; then
    tr -d '[:space:]' < "$NOS_ROOT/VERSION"
  elif [ -f /etc/nos-release ]; then
    # shellcheck disable=SC1091
    ( . /etc/nos-release && printf '%s' "${NOS_VERSION:-unknown}" )
  elif [ -f /usr/share/nos/VERSION ]; then
    tr -d '[:space:]' < /usr/share/nos/VERSION
  else
    printf 'unknown'
  fi
}

# --- Utilitaires --------------------------------------------------------------
nos_has() { command -v "$1" >/dev/null 2>&1; }

nos_is_linux() { [ "$(uname -s)" = "Linux" ]; }

nos_is_root() { [ "${EUID:-$(id -u)}" -eq 0 ]; }

# Exécute une commande, ou l'affiche seulement si NOS_DRY_RUN=1
nos_run() {
  if [ "$NOS_DRY_RUN" = "1" ]; then
    printf '%s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
    return 0
  fi
  "$@"
}

# Exécute avec sudo si nécessaire (et si disponible)
nos_sudo() {
  if nos_is_root; then
    nos_run "$@"
  elif nos_has sudo; then
    nos_run sudo "$@"
  else
    nos_die "Cette action nécessite les droits administrateur (sudo introuvable)."
  fi
}

nos_apt_install() {
  nos_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

nos_apt_remove() {
  nos_sudo env DEBIAN_FRONTEND=noninteractive apt-get remove -y "$@"
}

# Ajoute une ligne à un fichier si elle n'y est pas déjà
nos_ensure_line() {
  local line="$1" file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF -- "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

# Version d'un exécutable (première ligne, nettoyée)
nos_tool_version() {
  local tool="$1"; shift
  local flag="${1:---version}"
  "$tool" "$flag" 2>&1 | head -n 1 | tr -d '\r' || true
}

# Détection du système
nos_os_id() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    ( . /etc/os-release && printf '%s' "${ID:-unknown}" )
  else
    uname -s | tr '[:upper:]' '[:lower:]'
  fi
}

nos_os_pretty() {
  if [ -f /etc/nos-release ]; then
    # shellcheck disable=SC1091
    ( . /etc/nos-release && printf '%s' "${NOS_PRETTY_NAME:-Naabiga OS}" )
  elif [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    ( . /etc/os-release && printf '%s' "${PRETTY_NAME:-unknown}" )
  else
    uname -sr
  fi
}

# --- Configuration utilisateur (~/.config/nos/config, format clé=valeur) -------
nos_config_get() {
  local key="$1" default="${2:-}"
  if [ -f "$NOS_CONFIG_FILE" ]; then
    local value
    value="$(grep -E "^${key}=" "$NOS_CONFIG_FILE" 2>/dev/null | tail -n 1 | cut -d= -f2- || true)"
    [ -n "$value" ] && { printf '%s' "$value"; return 0; }
  fi
  printf '%s' "$default"
}

nos_config_set() {
  local key="$1" value="$2"
  mkdir -p "$NOS_CONFIG_DIR"
  touch "$NOS_CONFIG_FILE"
  if grep -qE "^${key}=" "$NOS_CONFIG_FILE"; then
    local tmp
    tmp="$(mktemp)"
    grep -vE "^${key}=" "$NOS_CONFIG_FILE" > "$tmp" || true
    printf '%s=%s\n' "$key" "$value" >> "$tmp"
    mv "$tmp" "$NOS_CONFIG_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >> "$NOS_CONFIG_FILE"
  fi
}

# --- JSON minimal (sans jq) ------------------------------------------------------
nos_json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# --- Catalogue d'outils (TSV : id, catégorie, description, méthode, spec) ----------
NOS_CATALOG="${NOS_CATALOG:-$NOS_SHARE/catalog.tsv}"

nos_catalog_lookup() {
  local id="$1"
  [ -f "$NOS_CATALOG" ] || return 1
  grep -v '^#' "$NOS_CATALOG" | awk -F'\t' -v id="$id" '$1 == id { print; found=1 } END { exit !found }'
}

nos_catalog_list() {
  [ -f "$NOS_CATALOG" ] || return 1
  grep -v '^#' "$NOS_CATALOG" | grep -v '^[[:space:]]*$'
}

# --- Bannière -------------------------------------------------------------------
nos_banner() {
  printf '%s' "$C_GOLD"
  cat <<'EOF'
  _   _              _     _                ___  ____
 | \ | | __ _  __ _ | |__ (_) __ _  __ _   / _ \/ ___|
 |  \| |/ _` |/ _` || '_ \| |/ _` |/ _` | | | | \___ \
 | |\  | (_| | (_| || |_) | | (_| | (_| | | |_| |___) |
 |_| \_|\__,_|\__,_||_.__/|_|\__, |\__,_|  \___/|____/
                             |___/
EOF
  printf '%s' "$C_RESET"
  printf '  %sBuild Faster. Create Smarter.%s  —  v%s\n\n' "$C_DIM" "$C_RESET" "$(nos_version)"
}
