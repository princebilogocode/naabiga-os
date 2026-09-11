#!/usr/bin/env bash
# Vérifie le style des textes du dépôt : pas de tiret cadratin ni de tiret demi-cadratin
# (on écrit avec des deux-points, des virgules ou des parenthèses).
# Usage : bash scripts/check-style.sh   (fichiers suivis par Git, hors LICENSE et binaires)
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

# Octets UTF-8 des tirets (indépendant de la locale du système ou du runner CI)
EM_DASH=$'\xe2\x80\x94'
EN_DASH=$'\xe2\x80\x93'

files="$(git ls-files 2>/dev/null | grep -vE '^LICENSE$|\.(png|jpe?g|gif|ico|woff2?|ttf|otf|zip|gz|xz|iso|deb)$' || true)"
[ -n "$files" ] || files="$(find . -type f -not -path './.git/*' -not -path './site/*' -not -path './build/out/*' -not -name LICENSE | sed 's|^\./||')"

hits="$(printf '%s\n' "$files" | tr '\n' '\0' | LC_ALL=C xargs -0 grep -nHa -e "$EM_DASH" -e "$EN_DASH" -- 2>/dev/null || true)"
if [ -n "$hits" ]; then
  echo "✘ Tirets cadratins ou demi-cadratins détectés (remplacez par « : », une virgule ou des parenthèses) :"
  printf '%s\n' "$hits" | sed 's/^/    /'
  exit 1
fi
echo "✔ Style OK ($(printf '%s\n' "$files" | wc -l | tr -d ' ') fichiers vérifiés)."
