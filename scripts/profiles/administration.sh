#!/usr/bin/env bash
# Optimisations N-OS — profil Administration (administration publique, collectivités, entreprises, ONG)
# Durcissement, sauvegardes, antivirus, inventaire, politiques dconf, préparation à l'intégration AD
# Exécuté en root par : nos profile apply administration
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$DIR/bureautique.sh" ] && bash "$DIR/bureautique.sh" >/dev/null 2>&1 || true

echo "== Administration : durcissement"
# Pare-feu : entrant refusé, pas d'exception ports de dev
if command -v ufw >/dev/null 2>&1; then
  for port in 3000 5173 8000 8080; do
    $SUDO ufw delete allow from 10.0.0.0/8 to any port "$port" proto tcp >/dev/null 2>&1 || true
    $SUDO ufw delete allow from 192.168.0.0/16 to any port "$port" proto tcp >/dev/null 2>&1 || true
  done
  $SUDO ufw --force enable >/dev/null 2>&1 || true
fi
# sudo journalisé, délai de mot de passe court
$SUDO tee /etc/sudoers.d/90-naabiga-admin >/dev/null <<'EOF'
Defaults        logfile="/var/log/sudo.log"
Defaults        timestamp_timeout=5
Defaults        passwd_tries=3
EOF
$SUDO chmod 0440 /etc/sudoers.d/90-naabiga-admin
# Mises à jour de sécurité automatiques avec redémarrage hors heures de bureau
$SUDO tee /etc/apt/apt.conf.d/52naabiga-admin >/dev/null <<'EOF'
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF
# Verrouillage automatique et politiques dconf verrouillées (l'utilisateur ne peut pas les changer)
$SUDO mkdir -p /etc/dconf/db/local.d/locks
$SUDO tee /etc/dconf/db/local.d/30-naabiga-administration >/dev/null <<'EOF'
# Naabiga OS — profil Administration
[org/cinnamon]
favorite-apps=['nemo.desktop', 'libreoffice-writer.desktop', 'libreoffice-calc.desktop', 'thunderbird.desktop', 'firefox.desktop', 'org.remmina.Remmina.desktop', 'keepassxc.desktop', 'simple-scan.desktop', 'nos-center.desktop', 'cinnamon-settings.desktop']

[org/cinnamon/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 120
idle-activation-enabled=true

[org/cinnamon/desktop/session]
idle-delay=uint32 300

[org/cinnamon/desktop/media-handling]
autorun-never=true
automount-open=false
EOF
$SUDO tee /etc/dconf/db/local.d/locks/naabiga-administration >/dev/null <<'EOF'
/org/cinnamon/desktop/screensaver/lock-enabled
/org/cinnamon/desktop/screensaver/lock-delay
/org/cinnamon/desktop/media-handling/autorun-never
EOF
$SUDO dconf update 2>/dev/null || true

# Option : périphériques USB de stockage en lecture seule (nos config set usb-readonly 1)
USB_RO="$(sudo -u "${SUDO_USER:-$(id -un)}" bash -c 'grep -E "^usb-readonly=" "${XDG_CONFIG_HOME:-$HOME/.config}/nos/config" 2>/dev/null | cut -d= -f2' 2>/dev/null || true)"
if [ "$USB_RO" = "1" ]; then
  $SUDO tee /etc/udev/rules.d/80-naabiga-usb-readonly.rules >/dev/null <<'EOF'
# Naabiga OS — stockage USB en lecture seule (profil Administration)
ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ATTR{ro}="1"
EOF
  $SUDO udevadm control --reload-rules 2>/dev/null || true
  echo "  stockage USB en lecture seule"
fi

echo "== Administration : antivirus et sauvegardes"
if command -v freshclam >/dev/null 2>&1; then
  $SUDO systemctl enable --now clamav-freshclam.service >/dev/null 2>&1 || true
  # Analyse hebdomadaire des dossiers utilisateurs (dimanche 05:00), rapport dans /var/log/nos-clamav.log
  $SUDO tee /etc/cron.d/naabiga-clamav >/dev/null <<'EOF'
0 5 * * 0 root /usr/bin/clamscan -ri --exclude-dir='^/home/[^/]+/\.cache' /home >> /var/log/nos-clamav.log 2>&1
EOF
  echo "  ClamAV : mises à jour actives, analyse hebdomadaire"
fi
if command -v timeshift >/dev/null 2>&1; then
  $SUDO timeshift --create --comments "N-OS profil Administration" --tags D >/dev/null 2>&1 || true
fi

echo "== Administration : inventaire de parc"
if command -v fusioninventory-agent >/dev/null 2>&1; then
  # Serveur GLPI configurable : nos config set glpi-server https://glpi.exemple.bf/front/inventory.php
  GLPI="$(sudo -u "${SUDO_USER:-$(id -un)}" bash -c 'grep -E "^glpi-server=" "${XDG_CONFIG_HOME:-$HOME/.config}/nos/config" 2>/dev/null | cut -d= -f2' 2>/dev/null || true)"
  if [ -n "$GLPI" ]; then
    $SUDO mkdir -p /etc/fusioninventory/conf.d
    printf 'server = %s\ntag = naabiga-os\n' "$GLPI" | $SUDO tee /etc/fusioninventory/conf.d/naabiga.cfg >/dev/null
    $SUDO systemctl enable --now fusioninventory-agent >/dev/null 2>&1 || true
    echo "  inventaire vers $GLPI"
  else
    echo "  inventaire : définissez 'nos config set glpi-server <URL>' puis relancez le profil"
  fi
fi

echo "== Administration : intégration Active Directory"
if command -v realm >/dev/null 2>&1; then
  echo "  pour rejoindre un domaine : sudo realm join --user=Administrateur domaine.local  (voir docs/handbook/profiles.md)"
  # Création automatique du dossier personnel à la première connexion AD
  if command -v pam-auth-update >/dev/null 2>&1; then
    $SUDO pam-auth-update --enable mkhomedir >/dev/null 2>&1 || true
  fi
fi

echo "Profil Administration : optimisations appliquées."
