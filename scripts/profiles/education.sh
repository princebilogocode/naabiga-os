#!/usr/bin/env bash
# Optimisations N-OS — profil Enseignement supérieur
# Salles de TP, enseignants-chercheurs, étudiants : outils scientifiques prêts, gestion de salle, bande passante
# Exécuté en root par : nos profile apply education
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# Le profil Bureautique est un sous-ensemble utile (LibreOffice, impression, associations)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$DIR/bureautique.sh" ] && bash "$DIR/bureautique.sh" >/dev/null 2>&1 || true

echo "== Enseignement : environnement scientifique"
# Jupyter accessible à tous les utilisateurs via pipx (si installé) + noyau R si R est présent
if command -v R >/dev/null 2>&1; then
  $SUDO Rscript -e 'if (!requireNamespace("IRkernel", quietly=TRUE)) { install.packages("IRkernel", repos="https://cloud.r-project.org"); IRkernel::installspec(user=FALSE) }' >/dev/null 2>&1 || true
fi
# Miroir CRAN par défaut
$SUDO mkdir -p /etc/R
[ -f /etc/R/Rprofile.site ] && ! grep -q 'cloud.r-project.org' /etc/R/Rprofile.site && \
  echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' | $SUDO tee -a /etc/R/Rprofile.site >/dev/null

# LaTeX : cache des polices et langue française
command -v mktexlsr >/dev/null 2>&1 && $SUDO mktexlsr >/dev/null 2>&1 || true

echo "== Enseignement : salle de TP"
# Mode « salle de TP » : compte étudiant local générique désactivé par défaut, activable par l'enseignant.
# nos config set classroom 1 puis : sudo bash /usr/lib/nos/scripts/profiles/education.sh
CLASSROOM="$(sudo -u "${SUDO_USER:-$(id -un)}" bash -c 'grep -E "^classroom=" "${XDG_CONFIG_HOME:-$HOME/.config}/nos/config" 2>/dev/null | cut -d= -f2' 2>/dev/null || true)"
if [ "$CLASSROOM" = "1" ]; then
  if ! id etudiant >/dev/null 2>&1; then
    $SUDO useradd -m -s /bin/bash -c "Compte étudiant (salle de TP)" etudiant
    $SUDO passwd -d etudiant >/dev/null 2>&1 || true
    echo "  compte 'etudiant' créé (sans mot de passe, sans sudo)"
  fi
  # Nettoyage du dossier étudiant à chaque déconnexion (session « kiosque » légère)
  $SUDO tee /etc/lightdm/lightdm.conf.d/60-nos-classroom.conf >/dev/null <<'EOF'
[Seat:*]
session-cleanup-script=/usr/lib/nos/scripts/profiles/classroom-cleanup.sh
EOF
  $SUDO tee /usr/lib/nos/scripts/profiles/classroom-cleanup.sh >/dev/null <<'EOF'
#!/bin/sh
# Réinitialise le dossier du compte 'etudiant' à la déconnexion (documents dans ~/Documents/A_GARDER conservés)
[ "$USER" = "etudiant" ] || exit 0
mkdir -p /home/etudiant/Documents/A_GARDER
find /home/etudiant -mindepth 1 -maxdepth 1 ! -name Documents ! -name .bashrc ! -name .profile -exec rm -rf {} + 2>/dev/null
find /home/etudiant/Documents -mindepth 1 -maxdepth 1 ! -name A_GARDER -exec rm -rf {} + 2>/dev/null
exit 0
EOF
  $SUDO chmod 0755 /usr/lib/nos/scripts/profiles/classroom-cleanup.sh
fi

# Veyon : service activé sur les postes élèves (le maître est configuré par l'enseignant avec veyon-configurator)
if command -v veyon-service >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
  $SUDO systemctl enable --now veyon.service >/dev/null 2>&1 || true
  echo "  Veyon activé (supervision de salle)"
fi

echo "== Enseignement : bande passante et cache"
# Les salles partagent souvent une connexion modeste : cache APT réutilisable et téléchargements limités
$SUDO tee /etc/apt/apt.conf.d/80naabiga-education >/dev/null <<'EOF'
// Naabiga OS — profil Enseignement : mises à jour hors heures de cours, pas de téléchargement des suggestions
APT::Periodic::Download-Upgradeable-Packages "1";
Acquire::Queue-Mode "access";
Acquire::Retries "3";
EOF
# Fenêtre de mises à jour automatiques la nuit
$SUDO mkdir -p /etc/systemd/system/apt-daily.timer.d /etc/systemd/system/apt-daily-upgrade.timer.d
printf '[Timer]\nOnCalendar=\nOnCalendar=*-*-* 02:00\nRandomizedDelaySec=1h\n' | $SUDO tee /etc/systemd/system/apt-daily.timer.d/override.conf >/dev/null
printf '[Timer]\nOnCalendar=\nOnCalendar=*-*-* 03:00\nRandomizedDelaySec=1h\n' | $SUDO tee /etc/systemd/system/apt-daily-upgrade.timer.d/override.conf >/dev/null
$SUDO systemctl daemon-reload 2>/dev/null || true

echo "== Enseignement : bureau"
$SUDO mkdir -p /etc/dconf/db/local.d
$SUDO tee /etc/dconf/db/local.d/20-naabiga-education >/dev/null <<'EOF'
# Naabiga OS — profil Enseignement supérieur
[org/cinnamon]
favorite-apps=['nemo.desktop', 'firefox.desktop', 'libreoffice-writer.desktop', 'texstudio.desktop', 'code.desktop', 'gnome-terminal.desktop', 'org.geogebra.GeoGebra.desktop', 'xournalpp.desktop', 'nos-center.desktop', 'cinnamon-settings.desktop']

[org/cinnamon/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 900
EOF
$SUDO dconf update 2>/dev/null || true

echo "Profil Enseignement supérieur : optimisations appliquées."
echo "Salle de TP : 'nos config set classroom 1' puis relancer 'nos profile apply education' pour créer le compte étudiant."
