#!/usr/bin/env bash
# Construit les paquets .deb N-OS avec dpkg-deb (sans debhelper, reproductible)
#   nos-cli       : CLI, Doctor, SDK Manager, AI Hub
#   nos-branding  : logo, fonds d'écran, Plymouth, GRUB, /etc/nos-release
#   nos-desktop   : réglages Cinnamon par défaut (dconf), thème
#   nos-base      : métapaquet — dépendances de la plateforme de développement + scripts système
# Usage : bash build/build-packages.sh        (sortie : build/out/packages/*.deb)
#         OUT=/chemin bash build/build-packages.sh
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
DEB_VERSION="${VERSION//-/\~}"   # 1.0.0-alpha.1 -> 1.0.0~alpha.1 (ordre de tri Debian)
OUT="${OUT:-$ROOT/build/out/packages}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
ARCH="all"

command -v dpkg-deb >/dev/null || { echo "dpkg-deb requis (sudo apt install dpkg-dev)"; exit 1; }
mkdir -p "$OUT"

render_control() {
  # Remplace @VERSION@ dans packages/<pkg>/DEBIAN/control
  local pkg="$1" dest="$2"
  mkdir -p "$dest/DEBIAN"
  sed -e "s/@VERSION@/$DEB_VERSION/g" "$ROOT/packages/$pkg/DEBIAN/control" > "$dest/DEBIAN/control"
  local f
  for f in postinst postrm preinst prerm conffiles; do
    if [ -f "$ROOT/packages/$pkg/DEBIAN/$f" ]; then
      cp "$ROOT/packages/$pkg/DEBIAN/$f" "$dest/DEBIAN/$f"
      [ "$f" = conffiles ] || chmod 0755 "$dest/DEBIAN/$f"
    fi
  done
}

build_pkg() {
  local pkg="$1" dest="$WORK/$1"
  local deb="$OUT/${pkg}_${DEB_VERSION}_${ARCH}.deb"
  find "$dest" -type d -exec chmod 0755 {} +
  fakeroot_cmd=()
  command -v fakeroot >/dev/null && fakeroot_cmd=(fakeroot)
  "${fakeroot_cmd[@]}" dpkg-deb --build --root-owner-group "$dest" "$deb" >/dev/null
  echo "  $(basename "$deb")"
}

echo "Construction des paquets N-OS $VERSION ($DEB_VERSION)"

# --- nos-cli -------------------------------------------------------------------
d="$WORK/nos-cli"; render_control nos-cli "$d"
DESTDIR="$d" PREFIX=/usr bash "$ROOT/build/install-cli.sh"
mkdir -p "$d/usr/share/doc/nos-cli"
cp "$ROOT/LICENSE" "$d/usr/share/doc/nos-cli/copyright"
build_pkg nos-cli

# --- nos-branding ----------------------------------------------------------------
d="$WORK/nos-branding"; render_control nos-branding "$d"
mkdir -p "$d/usr/share/nos/branding" "$d/usr/share/backgrounds/naabiga" "$d/usr/share/plymouth/themes/naabiga" "$d/boot/grub/themes/naabiga" "$d/usr/share/icons/hicolor/512x512/apps" "$d/etc" "$d/usr/share/pixmaps"
cp "$ROOT/branding/logo/naabiga-os-logo.png" "$d/usr/share/nos/branding/logo.png"
cp "$ROOT/branding/logo/naabiga-os-logo.png" "$d/usr/share/icons/hicolor/512x512/apps/naabiga-os.png"
cp "$ROOT/branding/logo/naabiga-os-logo.png" "$d/usr/share/pixmaps/naabiga-os.png"
cp "$ROOT/branding/logo/naabiga-os-logo.png" "$d/usr/share/plymouth/themes/naabiga/logo.png"
cp "$ROOT"/branding/wallpapers/*.svg "$d/usr/share/backgrounds/naabiga/" 2>/dev/null || true
cp "$ROOT"/branding/wallpapers/*.png "$d/usr/share/backgrounds/naabiga/" 2>/dev/null || true
cp "$ROOT"/desktop/plymouth/* "$d/usr/share/plymouth/themes/naabiga/"
cp "$ROOT"/desktop/grub/* "$d/boot/grub/themes/naabiga/"
cp "$ROOT/branding/palette/naabiga.json" "$d/usr/share/nos/branding/palette.json"
sed -e "s/@VERSION@/$VERSION/g" "$ROOT/packages/nos-branding/nos-release.in" > "$d/etc/nos-release"
build_pkg nos-branding

# --- nos-desktop ------------------------------------------------------------------
d="$WORK/nos-desktop"; render_control nos-desktop "$d"
mkdir -p "$d/etc/dconf/db/local.d" "$d/etc/dconf/profile" "$d/usr/share/glib-2.0/schemas" "$d/etc/skel/.config" "$d/usr/share/applications" "$d/etc/lightdm/lightdm.conf.d" "$d/etc/lightdm/slick-greeter.conf.d"
cp "$ROOT/desktop/dconf/00-naabiga-defaults" "$d/etc/dconf/db/local.d/00-naabiga-defaults"
cp "$ROOT/desktop/dconf/profile-user" "$d/etc/dconf/profile/user"
cp "$ROOT/desktop/cinnamon/99-naabiga.conf" "$d/etc/lightdm/lightdm.conf.d/99-naabiga.conf"
cp "$ROOT/desktop/cinnamon/99-naabiga-greeter.conf" "$d/etc/lightdm/slick-greeter.conf.d/99-naabiga.conf"
cp "$ROOT"/desktop/cinnamon/*.desktop "$d/usr/share/applications/"
build_pkg nos-desktop

# --- nos-base ----------------------------------------------------------------------
d="$WORK/nos-base"; render_control nos-base "$d"
# Les scripts (/usr/lib/nos/scripts) sont livrés par nos-cli ; nos-base ne fournit que le service et la configuration
mkdir -p "$d/lib/systemd/system" "$d/etc/sysctl.d" "$d/etc/apt/apt.conf.d"
cp "$ROOT/packages/nos-base/nos-first-boot.service" "$d/lib/systemd/system/"
cp "$ROOT/packages/nos-base/99-naabiga-sysctl.conf" "$d/etc/sysctl.d/"
cp "$ROOT/packages/nos-base/99-naabiga-apt.conf" "$d/etc/apt/apt.conf.d/99naabiga"
build_pkg nos-base

echo "Paquets dans $OUT"
