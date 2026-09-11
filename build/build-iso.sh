#!/usr/bin/env bash
# Construit l'ISO Naabiga OS avec live-build (Ubuntu 24.04 LTS "noble" + Cinnamon + Calamares)
# Prérequis : Ubuntu 24.04, sudo, live-build debootstrap xorriso squashfs-tools isolinux syslinux-common grub-efi-amd64-bin mtools dosfstools
# Usage : sudo bash build/build-iso.sh            (sortie : build/out/naabiga-os-<version>-amd64.iso)
#         NOS_MIRROR=http://archive.ubuntu.com/ubuntu  NOS_ARCH=amd64  sudo bash build/build-iso.sh
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
ARCH="${NOS_ARCH:-amd64}"
OUT="${OUT:-$ROOT/build/out}"
ISO_DIR="$ROOT/iso"
PKG_DIR="$ROOT/build/out/packages"
ISO_NAME="naabiga-os-${VERSION}-${ARCH}"

[ "$(id -u)" -eq 0 ] || { echo "live-build nécessite root : sudo bash build/build-iso.sh"; exit 1; }
for t in lb debootstrap xorriso mksquashfs; do
  command -v "$t" >/dev/null || { echo "Outil manquant : $t (sudo apt install live-build debootstrap xorriso squashfs-tools)"; exit 1; }
done

if ! ls "$PKG_DIR"/*.deb >/dev/null 2>&1; then
  echo "Aucun paquet N-OS dans $PKG_DIR : construction…"
  bash "$ROOT/build/build-packages.sh"
fi

mkdir -p "$OUT"
cd "$ISO_DIR"

echo "== Nettoyage"
lb clean --purge >/dev/null 2>&1 || true
rm -rf config/packages.chroot config/binary config/bootstrap config/chroot config/common config/source

echo "== Paquets N-OS injectés dans l'image"
mkdir -p config/packages.chroot
cp "$PKG_DIR"/*.deb config/packages.chroot/

echo "== Installateur Calamares et fichiers inclus"
rm -rf config/includes.chroot/etc/calamares config/includes.chroot/usr/share/applications config/includes.chroot/etc/skel/Desktop
mkdir -p config/includes.chroot/etc/calamares/branding/naabiga config/includes.chroot/usr/share/applications config/includes.chroot/etc/skel/Desktop
cp "$ROOT/installer/calamares/settings.conf" config/includes.chroot/etc/calamares/
cp -r "$ROOT/installer/calamares/modules" config/includes.chroot/etc/calamares/
cp "$ROOT"/installer/calamares/branding/naabiga/* config/includes.chroot/etc/calamares/branding/naabiga/
cp "$ROOT/branding/logo/naabiga-os-logo.png" config/includes.chroot/etc/calamares/branding/naabiga/logo.png
cp "$ROOT/branding/logo/naabiga-os-logo.png" config/includes.chroot/etc/calamares/branding/naabiga/welcome.png
cp "$ROOT/installer/calamares/naabiga-install.desktop" config/includes.chroot/usr/share/applications/
cp "$ROOT/installer/calamares/naabiga-install.desktop" config/includes.chroot/etc/skel/Desktop/
if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
  bash "$ROOT/build/gen-assets.sh" "$ROOT/build/out/assets" >/dev/null
  mkdir -p config/includes.chroot/usr/share/plymouth/themes/naabiga config/includes.chroot/boot/grub/themes/naabiga
  cp "$ROOT"/build/out/assets/plymouth/* config/includes.chroot/usr/share/plymouth/themes/naabiga/
  cp "$ROOT"/build/out/assets/grub/* config/includes.chroot/boot/grub/themes/naabiga/
else
  echo "  (ImageMagick absent : images Plymouth/GRUB non générées, thèmes en mode dégradé)"
fi

echo "== Configuration live-build"
export NOS_VERSION="$VERSION" NOS_ARCH="$ARCH"
bash auto/config

echo "== Construction (peut durer 30 à 90 min selon la connexion)"
lb build 2>&1 | tee "$OUT/${ISO_NAME}.log"

ISO_SRC="$(find . -maxdepth 1 -name 'live-image-*.hybrid.iso' -printf '%f
' 2>/dev/null | head -n 1 || true)"
[ -n "$ISO_SRC" ] || { echo "ISO introuvable, voir $OUT/${ISO_NAME}.log"; exit 1; }
mv "$ISO_SRC" "$OUT/${ISO_NAME}.iso"
cd "$OUT"
sha256sum "${ISO_NAME}.iso" > "${ISO_NAME}.iso.sha256"
if [ -n "${NOS_GPG_KEY:-}" ] && command -v gpg >/dev/null; then
  gpg --batch --yes --local-user "$NOS_GPG_KEY" --armor --detach-sign "${ISO_NAME}.iso.sha256"
fi

echo
echo "ISO : $OUT/${ISO_NAME}.iso ($(du -h "${ISO_NAME}.iso" | cut -f1))"
echo "SHA256 : $(cut -d' ' -f1 "${ISO_NAME}.iso.sha256")"
