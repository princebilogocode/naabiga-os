#!/usr/bin/env bash
# N-OS SDK Manager : plusieurs versions de Flutter, Java, Node.js et Android SDK
# Copyright (C) 2026 ICONEDOR, Burkina Faso
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Arborescence : ~/.nos/sdk/<sdk>/<version>/   +   ~/.nos/sdk/<sdk>/current -> <version>
# Environnement : ~/.nos/env.sh (PATH, JAVA_HOME, ANDROID_HOME, FLUTTER_ROOT)

SDK_NAMES=(flutter java node android)
NOS_ANDROID_CMDLINE_URL="${NOS_ANDROID_CMDLINE_URL:-https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip}"
NOS_ANDROID_PACKAGES="${NOS_ANDROID_PACKAGES:-platform-tools build-tools;34.0.0 platforms;android-34}"

sdk_arch() {
  case "$(uname -m)" in
    x86_64) printf 'x64' ;;
    aarch64|arm64) printf 'arm64' ;;
    *) printf '%s' "$(uname -m)" ;;
  esac
}

sdk_dir() { printf '%s/%s' "$NOS_SDK_DIR" "$1"; }

sdk_is_known() {
  local s
  for s in "${SDK_NAMES[@]}"; do [ "$s" = "$1" ] && return 0; done
  return 1
}

sdk_installed_versions() {
  local dir
  dir="$(sdk_dir "$1")"
  [ -d "$dir" ] || return 0
  find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name current -printf '%f\n' 2>/dev/null | sort -V
}

sdk_current_version() {
  local link
  link="$(sdk_dir "$1")/current"
  [ -L "$link" ] || return 1
  basename "$(readlink "$link")"
}

sdk_require_tools() {
  local t
  for t in "$@"; do
    nos_has "$t" || nos_die "Outil requis manquant : $t (sudo apt install $t)"
  done
}

# --- Téléchargement -----------------------------------------------------------
sdk_download() {
  local url="$1" dest="$2"
  nos_info "Téléchargement : $url"
  if nos_has curl; then
    nos_run curl -fL --progress-bar -o "$dest" "$url"
  elif nos_has wget; then
    nos_run wget -q --show-progress -O "$dest" "$url"
  else
    nos_die "curl ou wget requis."
  fi
}

# --- Flutter --------------------------------------------------------------------
sdk_install_flutter() {
  local version="${1:-stable}" dest
  dest="$(sdk_dir flutter)/$version"
  sdk_require_tools git
  if [ -d "$dest" ]; then nos_info "Flutter $version déjà installé ($dest)"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  case "$version" in
    stable|beta|master)
      nos_run git clone --depth 1 -b "$version" https://github.com/flutter/flutter.git "$dest" ;;
    *)
      nos_run git clone --depth 1 -b "$version" https://github.com/flutter/flutter.git "$dest" ;;
  esac
  [ "$NOS_DRY_RUN" = 1 ] || "$dest/bin/flutter" --version --suppress-analytics >/dev/null 2>&1 || true
  nos_ok "Flutter $version installé."
}

# --- Java (Eclipse Temurin via l'API Adoptium) -------------------------------------
sdk_install_java() {
  local version="${1:-17}" dest arch
  dest="$(sdk_dir java)/$version"
  if [ -d "$dest" ]; then nos_info "Java $version déjà installé ($dest)"; return 0; fi
  sdk_require_tools tar
  arch="$(sdk_arch)"
  [ "$arch" = "arm64" ] && arch="aarch64"
  local url="https://api.adoptium.net/v3/binary/latest/${version}/ga/linux/${arch}/jdk/hotspot/normal/eclipse"
  local tmp
  tmp="$(mktemp -d)"
  sdk_download "$url" "$tmp/jdk.tar.gz"
  mkdir -p "$dest"
  nos_run tar -xzf "$tmp/jdk.tar.gz" -C "$dest" --strip-components=1
  rm -rf "$tmp"
  nos_ok "Java (Temurin) $version installé."
}

# --- Node.js ----------------------------------------------------------------------
sdk_resolve_node_version() {
  local want="$1" index
  sdk_require_tools curl
  index="$(curl -fsSL https://nodejs.org/dist/index.json)" || nos_die "Impossible de joindre nodejs.org"
  case "$want" in
    lts|latest-lts)
      # première entrée dont "lts" n'est pas false
      printf '%s' "$index" | tr '{' '\n' | grep -v '"lts":false' | grep -o '"version":"v[0-9.]*"' | head -n 1 | grep -o 'v[0-9.]*' ;;
    latest)
      printf '%s' "$index" | grep -o '"version":"v[0-9.]*"' | head -n 1 | grep -o 'v[0-9.]*' ;;
    [0-9]*)
      local major="${want%%.*}"
      if [ "$want" = "$major" ]; then
        printf '%s' "$index" | grep -o "\"version\":\"v${major}\.[0-9.]*\"" | head -n 1 | grep -o 'v[0-9.]*'
      else
        printf 'v%s' "${want#v}"
      fi ;;
    *) nos_die "Version Node inconnue : $want" ;;
  esac
}

sdk_install_node() {
  local want="${1:-lts}" version dest arch
  if [ "$NOS_DRY_RUN" = 1 ]; then version="v22.0.0"; else version="$(sdk_resolve_node_version "$want")"; fi
  [ -n "$version" ] || nos_die "Impossible de résoudre la version Node '$want'"
  dest="$(sdk_dir node)/${version#v}"
  if [ -d "$dest" ]; then nos_info "Node $version déjà installé ($dest)"; sdk_alias_node "$want" "${version#v}"; return 0; fi
  sdk_require_tools tar xz
  arch="$(sdk_arch)"
  local url="https://nodejs.org/dist/${version}/node-${version}-linux-${arch}.tar.xz"
  local tmp
  tmp="$(mktemp -d)"
  sdk_download "$url" "$tmp/node.tar.xz"
  mkdir -p "$dest"
  nos_run tar -xJf "$tmp/node.tar.xz" -C "$dest" --strip-components=1
  rm -rf "$tmp"
  sdk_alias_node "$want" "${version#v}"
  nos_ok "Node.js $version installé."
}

# alias "lts" -> version réelle (symlink) pour que "nos sdk use node lts" fonctionne
sdk_alias_node() {
  local want="$1" real="$2"
  case "$want" in
    lts|latest) nos_run ln -sfn "$real" "$(sdk_dir node)/$want" ;;
  esac
}

# --- Android SDK --------------------------------------------------------------------
sdk_install_android() {
  local version="${1:-latest}" dest
  dest="$(sdk_dir android)/$version"
  if [ -d "$dest/cmdline-tools/latest" ]; then nos_info "Android SDK déjà installé ($dest)"; return 0; fi
  sdk_require_tools unzip
  nos_has java || nos_die "Java est requis pour sdkmanager : nos sdk install java 17"
  local tmp
  tmp="$(mktemp -d)"
  sdk_download "$NOS_ANDROID_CMDLINE_URL" "$tmp/cmdline-tools.zip"
  mkdir -p "$dest/cmdline-tools"
  nos_run unzip -q "$tmp/cmdline-tools.zip" -d "$tmp"
  nos_run mv "$tmp/cmdline-tools" "$dest/cmdline-tools/latest"
  rm -rf "$tmp"
  local sdkmanager="$dest/cmdline-tools/latest/bin/sdkmanager"
  if [ "$NOS_DRY_RUN" != 1 ]; then
    yes | "$sdkmanager" --sdk_root="$dest" --licenses >/dev/null 2>&1 || true
    # shellcheck disable=SC2086
    "$sdkmanager" --sdk_root="$dest" $NOS_ANDROID_PACKAGES
  else
    nos_run "$sdkmanager" --sdk_root="$dest" --licenses
    # shellcheck disable=SC2086
    nos_run "$sdkmanager" --sdk_root="$dest" $NOS_ANDROID_PACKAGES
  fi
  nos_ok "Android SDK installé ($dest)."
}

# --- Environnement --------------------------------------------------------------------
sdk_write_env() {
  mkdir -p "$NOS_HOME"
  local tmp
  tmp="$(mktemp)"
  {
    printf '# Généré par N-OS SDK Manager : ne pas éditer à la main (nos sdk use …)\n'
    printf '# %s\n' "$(date '+%Y-%m-%d %H:%M')"
    printf 'export NOS_SDK_DIR="%s"\n' "$NOS_SDK_DIR"
    printf 'export PATH="$HOME/.local/bin:$PATH"\n'
    if [ -L "$(sdk_dir java)/current" ]; then
      printf 'export JAVA_HOME="%s/java/current"\n' "$NOS_SDK_DIR"
      printf 'export PATH="$JAVA_HOME/bin:$PATH"\n'
    fi
    if [ -L "$(sdk_dir android)/current" ]; then
      printf 'export ANDROID_HOME="%s/android/current"\n' "$NOS_SDK_DIR"
      printf 'export ANDROID_SDK_ROOT="$ANDROID_HOME"\n'
      printf 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"\n'
    fi
    if [ -L "$(sdk_dir flutter)/current" ]; then
      printf 'export FLUTTER_ROOT="%s/flutter/current"\n' "$NOS_SDK_DIR"
      printf 'export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"\n'
    fi
    if [ -L "$(sdk_dir node)/current" ]; then
      printf 'export PATH="%s/node/current/bin:$PATH"\n' "$NOS_SDK_DIR"
    fi
    [ -d "$HOME/.nos/npm-global/bin" ] && printf 'export PATH="$HOME/.nos/npm-global/bin:$PATH"\n'
    [ -d "$HOME/.cargo/bin" ] && printf 'export PATH="$HOME/.cargo/bin:$PATH"\n'
    printf 'export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-$(command -v google-chrome || command -v chromium || true)}"\n'
  } > "$tmp"
  mv "$tmp" "$NOS_ENV_FILE"
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] && nos_ensure_line '[ -f "$HOME/.nos/env.sh" ] && . "$HOME/.nos/env.sh"' "$rc"
  done
  return 0
}

# --- Commandes ---------------------------------------------------------------------------
sdk_cmd_list() {
  local filter="${1:-}" s v cur
  for s in "${SDK_NAMES[@]}"; do
    [ -n "$filter" ] && [ "$filter" != "$s" ] && continue
    cur="$(sdk_current_version "$s" 2>/dev/null || true)"
    printf '%s%s%s' "$C_BOLD" "$s" "$C_RESET"
    [ -n "$cur" ] && printf ' %s(actif : %s)%s' "$C_GREEN" "$cur" "$C_RESET"
    printf '\n'
    local any=0
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      any=1
      if [ "$v" = "$cur" ]; then printf '  * %s\n' "$v"; else printf '    %s\n' "$v"; fi
    done < <(sdk_installed_versions "$s")
    [ "$any" = 0 ] && printf '    %s(aucune version : nos sdk install %s <version>)%s\n' "$C_DIM" "$s" "$C_RESET"
  done
}

sdk_cmd_install() {
  local sdk="${1:-}" version="${2:-}"
  sdk_is_known "$sdk" || nos_die "SDK inconnu : '$sdk' (flutter, java, node, android)"
  mkdir -p "$(sdk_dir "$sdk")"
  case "$sdk" in
    flutter) sdk_install_flutter "${version:-stable}" ;;
    java)    sdk_install_java "${version:-17}" ;;
    node)    sdk_install_node "${version:-lts}" ;;
    android) sdk_install_android "${version:-latest}" ;;
  esac
  # Première version installée → activée automatiquement
  if ! sdk_current_version "$sdk" >/dev/null 2>&1; then
    local first
    first="$(sdk_installed_versions "$sdk" | head -n 1)"
    if [ -n "$first" ]; then
      sdk_cmd_use "$sdk" "$first"
    fi
  fi
  return 0
}

sdk_cmd_use() {
  local sdk="${1:-}" version="${2:-}"
  sdk_is_known "$sdk" || nos_die "SDK inconnu : '$sdk'"
  if [ -z "$version" ]; then
    version="$(sdk_installed_versions "$sdk" | tail -n 1)"
    [ -n "$version" ] || nos_die "Aucune version de $sdk installée."
  fi
  local dir
  dir="$(sdk_dir "$sdk")/$version"
  [ -d "$dir" ] || nos_die "Version non installée : $sdk $version (nos sdk install $sdk $version)"
  ln -sfn "$version" "$(sdk_dir "$sdk")/current"
  sdk_write_env
  nos_ok "$sdk $version activé. Rechargez votre shell : source ~/.nos/env.sh"
}

sdk_cmd_remove() {
  local sdk="${1:-}" version="${2:-}"
  sdk_is_known "$sdk" || nos_die "SDK inconnu : '$sdk'"
  [ -n "$version" ] || nos_die "Usage : nos sdk remove <sdk> <version>"
  local dir
  dir="$(sdk_dir "$sdk")/$version"
  [ -d "$dir" ] || nos_die "Version non installée : $sdk $version"
  if [ "$(sdk_current_version "$sdk" 2>/dev/null || true)" = "$version" ]; then
    rm -f "$(sdk_dir "$sdk")/current"
  fi
  nos_run rm -rf "$dir"
  sdk_write_env
  nos_ok "$sdk $version supprimé."
}

sdk_cmd_current() {
  local s
  for s in "${SDK_NAMES[@]}"; do
    [ -n "${1:-}" ] && [ "$1" != "$s" ] && continue
    printf '%-8s %s\n' "$s" "$(sdk_current_version "$s" 2>/dev/null || printf -- '-')"
  done
}

sdk_usage() {
  cat <<EOF
Usage : nos sdk <commande> [sdk] [version]

Commandes :
  list [sdk]                 Versions installées et version active
  install <sdk> [version]    Installer une version (flutter stable|beta|3.24.5, java 17|21, node lts|22, android latest)
  use <sdk> [version]        Activer une version (met à jour ~/.nos/env.sh)
  remove <sdk> <version>     Supprimer une version
  current [sdk]              Versions actives
  env                        Afficher ~/.nos/env.sh
  dir                        Afficher le dossier des SDK

SDK gérés : flutter, java, node, android
EOF
}

sdk_main() {
  local action="${1:-list}"
  [ $# -gt 0 ] && shift
  case "$action" in
    list|ls)      sdk_cmd_list "$@" ;;
    install|add)  sdk_cmd_install "$@" ;;
    use|switch)   sdk_cmd_use "$@" ;;
    remove|rm)    sdk_cmd_remove "$@" ;;
    current)      sdk_cmd_current "$@" ;;
    env)          sdk_write_env; cat "$NOS_ENV_FILE" ;;
    dir)          printf '%s\n' "$NOS_SDK_DIR" ;;
    -h|--help|help) sdk_usage ;;
    *) nos_err "Commande sdk inconnue : $action"; sdk_usage; return 2 ;;
  esac
}
