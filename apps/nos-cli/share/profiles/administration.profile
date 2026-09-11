# Profil N-OS : administration (administration publique, collectivités, entreprises, ONG)
name=Administration
description=Bureautique sécurisée, gestion documentaire, accès distant, sauvegardes, antivirus, intégration Active Directory, inventaire de parc
tools=libreoffice thunderbird pdf-tools scanner keepassxc nextcloud remmina gnucash backup clamav veyon
apt=libreoffice-l10n-fr hunspell-fr-comprehensive fonts-crosextra-carlito fonts-crosextra-caladea fonts-liberation2 cups system-config-printer hplip simple-scan evince realmd sssd sssd-tools adcli samba-common-bin libnss-sss libpam-sss krb5-user packagekit fusioninventory-agent gnome-calendar gnome-contacts seahorse gufw
flatpak=org.onlyoffice.desktopeditors
optimizations=Durcissement (verrouillage 2 min, sudo journalisé, USB en lecture seule en option, ClamAV planifié, sauvegardes Déjà Dup), intégration domaine AD (nos admin join-domain), inventaire de parc, politiques dconf verrouillées
