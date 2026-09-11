#!/usr/bin/env bash
# Optimisation Flutter : télémétrie désactivée, dépendances Linux desktop, inotify
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# Dépendances pour flutter build linux
$SUDO apt-get install -y --no-install-recommends clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev >/dev/null 2>&1 || true

# Variables système : pas de télémétrie, pas d'analytics Dart
$SUDO tee /etc/profile.d/nos-flutter.sh >/dev/null <<'EOF'
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
EOF
# Miroir pub.dev configurable pour les connexions lentes (décommenter si besoin)
# echo 'export PUB_HOSTED_URL=https://pub.flutter-io.cn' | $SUDO tee -a /etc/profile.d/nos-flutter.sh
echo "Optimisation Flutter appliquée."
