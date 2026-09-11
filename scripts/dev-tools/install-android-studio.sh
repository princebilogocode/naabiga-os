#!/usr/bin/env bash
# Installe Android Studio dans /opt/android-studio et crée un lanceur
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

# Version stable connue ; surchargeable : ANDROID_STUDIO_URL=...
ANDROID_STUDIO_VERSION="${ANDROID_STUDIO_VERSION:-2024.2.1.12}"
ANDROID_STUDIO_URL="${ANDROID_STUDIO_URL:-https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz}"
DEST="/opt/android-studio"
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

if [ -x "$DEST/bin/studio.sh" ]; then
  echo "Android Studio est déjà installé dans $DEST"
  exit 0
fi

# Dépendances 64 bits / 32 bits requises par Android Studio et l'émulateur
$SUDO apt-get install -y --no-install-recommends libc6 libncurses6 libstdc++6 lib32z1 libbz2-1.0 libxrender1 libxtst6 libxi6 libfreetype6 libxft2 curl tar

tmp="$(mktemp -d)"
echo "Téléchargement d'Android Studio ${ANDROID_STUDIO_VERSION}…"
curl -fL --progress-bar -o "$tmp/studio.tar.gz" "$ANDROID_STUDIO_URL"
$SUDO mkdir -p "$DEST"
$SUDO tar -xzf "$tmp/studio.tar.gz" -C "$DEST" --strip-components=1
rm -rf "$tmp"

$SUDO ln -sf "$DEST/bin/studio.sh" /usr/local/bin/android-studio
$SUDO ln -sf "$DEST/bin/studio.sh" /usr/local/bin/studio.sh

$SUDO tee /usr/share/applications/android-studio.desktop >/dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=IDE officiel pour Android
Exec=$DEST/bin/studio.sh %f
Icon=$DEST/bin/studio.svg
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
EOF

# Accélération matérielle (KVM) pour l'émulateur
if [ -e /dev/kvm ] && [ -n "${SUDO_USER:-}" ]; then
  $SUDO usermod -aG kvm "$SUDO_USER" || true
fi

echo "Android Studio installé : lancez 'android-studio'."
