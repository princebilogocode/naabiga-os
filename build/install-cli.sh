#!/usr/bin/env bash
# Installe (ou désinstalle) la CLI nos, N-OS Doctor, SDK Manager et AI Hub sur le système
# Usage : sudo bash build/install-cli.sh [--uninstall]
#         DESTDIR=./tmp PREFIX=/usr bash build/install-cli.sh   (pour le packaging)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTDIR="${DESTDIR:-}"
PREFIX="${PREFIX:-/usr}"
LIBDIR="$DESTDIR$PREFIX/lib/nos"
BINDIR="$DESTDIR$PREFIX/bin"
SHAREDIR="$DESTDIR$PREFIX/share/nos"
PROFILED="$DESTDIR/etc/profile.d"
COMPLETIONS="$DESTDIR$PREFIX/share/bash-completion/completions"

uninstall() {
  rm -rf "$LIBDIR" "$SHAREDIR"
  rm -f "$BINDIR/nos" "$BINDIR/nos-doctor" "$PROFILED/nos.sh" "$COMPLETIONS/nos"
  echo "CLI nos désinstallée."
}

install_all() {
  if [ -z "$DESTDIR" ] && [ "$(id -u)" -ne 0 ]; then
    echo "Droits administrateur requis : sudo bash build/install-cli.sh"
    exit 1
  fi
  install -d "$LIBDIR/lib/commands" "$LIBDIR/doctor/checks" "$LIBDIR/sdk" "$LIBDIR/ai" "$LIBDIR/scripts/dev-tools" "$LIBDIR/scripts/optimizations" "$LIBDIR/scripts/first-boot" "$LIBDIR/scripts/profiles" "$BINDIR" "$SHAREDIR/profiles" "$PROFILED" "$COMPLETIONS"

  install -m 0644 "$ROOT/apps/nos-cli/lib/core.sh" "$LIBDIR/lib/"
  install -m 0644 "$ROOT"/apps/nos-cli/lib/commands/*.sh "$LIBDIR/lib/commands/"
  install -m 0644 "$ROOT/apps/nos-doctor/lib/doctor.sh" "$LIBDIR/doctor/"
  install -m 0644 "$ROOT"/apps/nos-doctor/lib/checks/*.sh "$LIBDIR/doctor/checks/"
  install -m 0644 "$ROOT/apps/nos-sdk/lib/sdk.sh" "$LIBDIR/sdk/"
  install -m 0644 "$ROOT/apps/nos-ai/lib/ai.sh" "$LIBDIR/ai/"
  install -m 0755 "$ROOT"/scripts/dev-tools/*.sh "$LIBDIR/scripts/dev-tools/"
  install -m 0755 "$ROOT"/scripts/optimizations/*.sh "$LIBDIR/scripts/optimizations/"
  install -m 0755 "$ROOT"/scripts/first-boot/*.sh "$LIBDIR/scripts/first-boot/"
  install -m 0644 "$ROOT/apps/nos-cli/share/catalog.tsv" "$SHAREDIR/"
  install -m 0644 "$ROOT"/apps/nos-cli/share/profiles/*.profile "$SHAREDIR/profiles/"
  install -m 0755 "$ROOT"/scripts/profiles/*.sh "$LIBDIR/scripts/profiles/"
  install -m 0644 "$ROOT/VERSION" "$SHAREDIR/VERSION"
  install -m 0755 "$ROOT/apps/nos-cli/bin/nos" "$BINDIR/nos"
  ln -sf nos "$BINDIR/nos-doctor"

  # Le binaire installé appelle 'nos doctor' quand il est invoqué comme nos-doctor
  cat > "$PROFILED/nos.sh" <<'EOF'
# Naabiga OS : environnement de développement utilisateur
[ -f "$HOME/.nos/env.sh" ] && . "$HOME/.nos/env.sh"
EOF
  chmod 0644 "$PROFILED/nos.sh"

  cat > "$COMPLETIONS/nos" <<'EOF'
# Complétion bash pour nos
_nos() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  case "$prev" in
    nos) COMPREPLY=($(compgen -W "doctor install remove update repair sdk ai profile welcome info config version help" -- "$cur")) ;;
    doctor) COMPREPLY=($(compgen -W "--repair --json --export --check --list --no-fail" -- "$cur")) ;;
    sdk) COMPREPLY=($(compgen -W "list install use remove current env dir" -- "$cur")) ;;
    ai) COMPREPLY=($(compgen -W "list install remove status update" -- "$cur")) ;;
    config) COMPREPLY=($(compgen -W "get set list path" -- "$cur")) ;;
    profile) COMPREPLY=($(compgen -W "list show apply dev bureautique education administration all" -- "$cur")) ;;
    welcome) COMPREPLY=($(compgen -W "--yes --profile --ide --ai --no-doctor --force --reset" -- "$cur")) ;;
    update) COMPREPLY=($(compgen -W "--system --sdk --ai --check --all" -- "$cur")) ;;
    info) COMPREPLY=($(compgen -W "--json" -- "$cur")) ;;
    install|remove)
      local catalog="${NOS_CATALOG:-/usr/share/nos/catalog.tsv}"
      [ -f "$catalog" ] && COMPREPLY=($(compgen -W "$(grep -v '^#' "$catalog" | cut -f1 | tr '\n' ' ')" -- "$cur")) ;;
  esac
}
complete -F _nos nos
EOF
  chmod 0644 "$COMPLETIONS/nos"

  if [ -z "$DESTDIR" ]; then
    echo "CLI nos $(tr -d '[:space:]' < "$ROOT/VERSION") installée dans $PREFIX/bin/nos"
    echo "Essayez : nos doctor"
  fi
}

case "${1:-}" in
  --uninstall|-u) uninstall ;;
  *) install_all ;;
esac
