#!/usr/bin/env bash
# Premier démarrage : français par défaut (clavier et locale), autres langues disponibles
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

if command -v locale-gen >/dev/null 2>&1; then
  grep -q '^fr_FR.UTF-8' /etc/locale.gen 2>/dev/null || sed -i 's/^# *fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
  grep -q '^en_US.UTF-8' /etc/locale.gen 2>/dev/null || sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  locale-gen >/dev/null 2>&1 || true
fi
if [ ! -s /etc/default/locale ]; then
  update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR:fr:en 2>/dev/null || true
fi
if [ -f /etc/default/keyboard ] && ! grep -q 'XKBLAYOUT="fr"' /etc/default/keyboard; then
  : # L'installateur Calamares définit déjà la disposition choisie ; on ne force rien.
fi
