#!/usr/bin/env bash
# Génère les images binaires (PNG) des thèmes Plymouth et GRUB à partir de la palette,
# pour ne pas versionner de fichiers binaires. Nécessite ImageMagick (convert).
# Usage : bash build/gen-assets.sh [dossier-de-sortie]   (défaut : build/out/assets)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/build/out/assets}"
RED="#D62828"; GOLD="#D4AF37"; BLACK="#111111"; GREY="#333333"

if command -v magick >/dev/null 2>&1; then IM=magick; elif command -v convert >/dev/null 2>&1; then IM=convert; else
  echo "ImageMagick requis (sudo apt install imagemagick)"; exit 1
fi

mkdir -p "$OUT/plymouth" "$OUT/grub"

# Plymouth
$IM -size 320x4 "xc:$GREY" "$OUT/plymouth/progress-bg.png"
$IM -size 320x4 "gradient:$GOLD-$RED" -rotate 90 -resize '320x4!' "$OUT/plymouth/progress-fg.png"
$IM "$ROOT/branding/logo/naabiga-os-logo.png" -resize 200x200 "$OUT/plymouth/logo.png"

# GRUB
$IM -size 1920x1080 "xc:$BLACK" "$OUT/grub/background.png"
$IM "$ROOT/branding/logo/naabiga-os-logo.png" -resize 128x128 "$OUT/grub/logo.png"
for part in c e n ne nw s se sw w; do
  $IM -size 8x8 "xc:$GOLD" "$OUT/grub/select_${part}.png"
  $IM -size 8x8 "xc:$GREY" "$OUT/grub/terminal_box_${part}.png"
done
for part in c n s; do
  $IM -size 6x6 "xc:$RED" "$OUT/grub/scrollbar_thumb_${part}.png"
done

echo "Assets générés dans $OUT"
