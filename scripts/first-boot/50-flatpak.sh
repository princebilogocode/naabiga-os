#!/usr/bin/env bash
# Premier démarrage : Flathub activé (Flatpak est le second format de paquets de N-OS, pas de Snap)
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

command -v flatpak >/dev/null 2>&1 || exit 0
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
echo "Flathub configuré."
