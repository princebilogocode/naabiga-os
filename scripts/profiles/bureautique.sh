#!/usr/bin/env bash
# Optimisations N-OS : profil Bureautique
# LibreOffice rapide et compatible Office, impression/scan actifs, associations de fichiers, autonomie
# Exécuté en root par : nos profile apply bureautique
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

echo "== Bureautique : LibreOffice"
# Réglages LibreOffice pour tous les utilisateurs (registrymodifications système)
# - préchargement (démarrage rapide), formats Office (docx/xlsx/pptx) proposés par défaut,
# - langue et autocorrection françaises, pas de télémétrie, polices de substitution Calibri/Cambria.
LO_XCU="/etc/libreoffice/registry/nos-bureautique.xcu"
if [ -d /etc/libreoffice ] || [ -d /usr/lib/libreoffice ]; then
  $SUDO mkdir -p /etc/libreoffice/registry
  $SUDO tee "$LO_XCU" >/dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="UseSystemFileDialog" oor:op="fuse"><value>true</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="FirstRun" oor:op="fuse"><value>false</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="ShowTipOfTheDay" oor:op="fuse"><value>false</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Save/Document"><prop oor:name="WarnAlienFormat" oor:op="fuse"><value>false</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Save/Document"><prop oor:name="AutoSave" oor:op="fuse"><value>true</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Save/Document"><prop oor:name="AutoSaveTimeIntervall" oor:op="fuse"><value>5</value></prop></item>
  <item oor:path="/org.openoffice.Office.Linguistic/General"><prop oor:name="DefaultLocale" oor:op="fuse"><value>fr-FR</value></prop></item>
  <item oor:path="/org.openoffice.Office.Linguistic/General"><prop oor:name="UILocale" oor:op="fuse"><value>fr-FR</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/VCL"><prop oor:name="UseSkia" oor:op="fuse"><value>true</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Font/Substitution"><prop oor:name="Replacement" oor:op="fuse"><value>true</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Font/Substitution/FontPairs/Calibri" oor:op="replace"><prop oor:name="ReplaceFont"><value>Calibri</value></prop><prop oor:name="SubstituteFont"><value>Carlito</value></prop><prop oor:name="Always"><value>false</value></prop><prop oor:name="OnScreenOnly"><value>false</value></prop></item>
  <item oor:path="/org.openoffice.Office.Common/Font/Substitution/FontPairs/Cambria" oor:op="replace"><prop oor:name="ReplaceFont"><value>Cambria</value></prop><prop oor:name="SubstituteFont"><value>Caladea</value></prop><prop oor:name="Always"><value>false</value></prop><prop oor:name="OnScreenOnly"><value>false</value></prop></item>
</oor:items>
EOF
  echo "  registre LibreOffice : $LO_XCU"
fi

echo "== Bureautique : impression et scan"
if command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl enable --now cups.service >/dev/null 2>&1 || true
  $SUDO systemctl enable --now cups-browsed.service >/dev/null 2>&1 || true   # réactivé (désactivé par fast-boot pour les devs)
  $SUDO systemctl enable --now avahi-daemon.service >/dev/null 2>&1 || true  # découverte d'imprimantes réseau
fi
# Accès scanner USB et lp pour les comptes humains
for g in scanner lpadmin; do getent group "$g" >/dev/null || $SUDO groupadd -f "$g"; done
while IFS=: read -r name _ uid _ _ home _; do
  [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ] && [ -d "$home" ] || continue
  $SUDO usermod -aG scanner,lpadmin "$name" 2>/dev/null || true
done < /etc/passwd

echo "== Bureautique : associations de fichiers (Office, PDF, courriel)"
$SUDO mkdir -p /usr/share/applications
$SUDO tee /usr/share/applications/nos-bureautique-mimeapps.list >/dev/null <<'EOF'
[Default Applications]
application/vnd.openxmlformats-officedocument.wordprocessingml.document=libreoffice-writer.desktop
application/msword=libreoffice-writer.desktop
application/vnd.oasis.opendocument.text=libreoffice-writer.desktop
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=libreoffice-calc.desktop
application/vnd.ms-excel=libreoffice-calc.desktop
application/vnd.oasis.opendocument.spreadsheet=libreoffice-calc.desktop
application/vnd.openxmlformats-officedocument.presentationml.presentation=libreoffice-impress.desktop
application/vnd.ms-powerpoint=libreoffice-impress.desktop
application/vnd.oasis.opendocument.presentation=libreoffice-impress.desktop
application/pdf=org.gnome.Evince.desktop
x-scheme-handler/mailto=thunderbird.desktop
EOF
# Fusion dans la liste système si absente
if [ -f /usr/share/applications/mimeapps.list ]; then
  grep -q 'libreoffice-writer.desktop' /usr/share/applications/mimeapps.list || \
    $SUDO sh -c 'tail -n +2 /usr/share/applications/nos-bureautique-mimeapps.list >> /usr/share/applications/mimeapps.list'
else
  $SUDO cp /usr/share/applications/nos-bureautique-mimeapps.list /usr/share/applications/mimeapps.list
fi
$SUDO update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

echo "== Bureautique : polices"
$SUDO fc-cache -f >/dev/null 2>&1 || true

echo "== Bureautique : bureau (favoris, économie d'énergie, sécurité)"
$SUDO mkdir -p /etc/dconf/db/local.d
$SUDO tee /etc/dconf/db/local.d/10-naabiga-bureautique >/dev/null <<'EOF'
# Naabiga OS : profil Bureautique
[org/cinnamon]
favorite-apps=['nemo.desktop', 'libreoffice-writer.desktop', 'libreoffice-calc.desktop', 'libreoffice-impress.desktop', 'thunderbird.desktop', 'firefox.desktop', 'simple-scan.desktop', 'nos-center.desktop', 'cinnamon-settings.desktop']

[org/cinnamon/desktop/interface]
gtk-theme='Yaru-red'
text-scaling-factor=1.1

[org/cinnamon/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 600

[org/cinnamon/settings-daemon/plugins/power]
sleep-display-ac=900
sleep-display-battery=300
sleep-inactive-battery-timeout=1200
EOF
$SUDO dconf update 2>/dev/null || true

# Économie d'énergie sur portable (TLP) si batterie détectée
if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  $SUDO apt-get install -y --no-install-recommends tlp >/dev/null 2>&1 && $SUDO systemctl enable --now tlp >/dev/null 2>&1 || true
  echo "  TLP activé (portable)"
fi

echo "Profil Bureautique : optimisations appliquées."
