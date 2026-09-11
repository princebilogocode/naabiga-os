#!/usr/bin/env bash
# Installe le compilateur Kotlin dans /opt/kotlinc
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

KOTLIN_VERSION="${KOTLIN_VERSION:-2.1.0}"
DEST="/opt/kotlinc"
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if command -v kotlinc >/dev/null 2>&1; then
  echo "Kotlin est déjà installé : $(kotlinc -version 2>&1 | head -n 1)"
  exit 0
fi

command -v java >/dev/null 2>&1 || { echo "Java est requis : nos sdk install java 17"; exit 1; }
$SUDO apt-get install -y --no-install-recommends curl unzip

tmp="$(mktemp -d)"
curl -fL --progress-bar -o "$tmp/kotlin.zip" "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip"
$SUDO rm -rf "$DEST"
$SUDO unzip -q "$tmp/kotlin.zip" -d /opt
rm -rf "$tmp"
for bin in kotlinc kotlin kotlinc-jvm; do
  $SUDO ln -sf "$DEST/bin/$bin" "/usr/local/bin/$bin"
done
echo "Kotlin ${KOTLIN_VERSION} installé."
