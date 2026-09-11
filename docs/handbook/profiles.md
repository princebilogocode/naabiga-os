# Profils d'usage (`nos profile`)

N-OS est conçu pour les développeurs, mais le même système sert aussi au **travail de bureau**, à **l'enseignement supérieur** et à **l'administration**. Un profil installe en une commande les outils du domaine et applique des optimisations dédiées.

```bash
nos profile list
nos profile show education
nos profile apply bureautique
nos profile apply education
nos profile apply administration
nos profile apply all
nos profile apply administration --no-optimize   # outils seulement
```

Les profils sont cumulables (un poste d'enseignant-chercheur : `dev` + `education`). Le Doctor tient compte des profils appliqués (vérification `office`).

## Développement (`dev`)

Profil par défaut de l'ISO. Outils : Git, VS Code, Java 17, Flutter, Android SDK, Node.js, Python, Docker. Optimisations : ZRAM, TRIM, SSD, démarrage rapide, Docker, Flutter, Android Studio.

## Bureautique (`bureautique`)

Pour secrétariats, gestion, PME, télétravail, cybercafés.

| Outils | Optimisations |
|---|---|
| LibreOffice complet en français (Writer, Calc, Impress, Draw, Base, Math), ONLYOFFICE (compatibilité Office), Thunderbird (courriel, agenda), PDF Arranger, OCRmyPDF (OCR français), Evince, Simple Scan, CUPS + HPLIP (imprimantes), KeePassXC, Nextcloud, GIMP, Inkscape, Zoom, Teams, Flameshot | LibreOffice rapide (Skia, sauvegarde auto 5 min, plus d'avertissement sur les formats .docx/.xlsx), polices de substitution **Calibri → Carlito**, **Cambria → Caladea**, dictionnaires et césure français, impression et scan activés (CUPS, Avahi, groupes `lpadmin`/`scanner`), associations de fichiers Office/PDF/mailto, thème clair, verrouillage 10 min, TLP sur portable |

## Enseignement supérieur (`education`)

Pour universités, écoles d'ingénieurs, salles de TP, enseignants-chercheurs, étudiants.

| Outils | Optimisations |
|---|---|
| Tout Bureautique + LaTeX (TeX Live recommandé, français, TeXstudio), JupyterLab, R (tidyverse) + noyau Jupyter, Octave, Scilab, Maxima, GeoGebra, Zotero, Anki, Calibre, OBS Studio (cours vidéo), Xournal++ (annotation, tableau blanc), Moodle Desktop, Veyon (supervision de salle), Python scientifique (numpy, scipy, pandas, matplotlib, sympy), pandoc, graphviz, Audacity, VLC | **Mode salle de TP** : `nos config set classroom 1` puis réappliquer → compte `etudiant` sans mot de passe ni sudo, dossier réinitialisé à la déconnexion (sauf `Documents/A_GARDER`) ; Veyon activé sur les postes ; mises à jour APT la nuit (02 h-04 h) et téléchargements limités pour préserver la bande passante partagée ; miroir CRAN configuré ; favoris orientés cours |

Le maître Veyon se configure sur le poste enseignant avec `veyon-configurator` (clés d'accès, liste des postes).

## Administration (`administration`)

Pour administrations publiques, collectivités, entreprises, ONG.

| Outils | Optimisations |
|---|---|
| Tout Bureautique + Remmina (RDP/VNC/SSH), GnuCash, Déjà Dup + Timeshift (sauvegardes), ClamAV + ClamTk, Signal Desktop, intégration Active Directory (realmd, sssd, adcli, Kerberos), agent d'inventaire FusionInventory/GLPI, Seahorse, Gufw | **Durcissement** : verrouillage 2 min (verrouillé par politique dconf), exécution automatique des supports désactivée, sudo journalisé (`/var/log/sudo.log`), 3 essais, redémarrage automatique après mises à jour de sécurité à 04 h, ports de dev fermés ; **USB en lecture seule** en option (`nos config set usb-readonly 1`) ; ClamAV avec analyse hebdomadaire ; instantané Timeshift initial ; inventaire vers GLPI (`nos config set glpi-server <URL>`) ; création automatique du dossier personnel pour les comptes AD |

### Rejoindre un domaine Active Directory

```bash
nos profile apply administration
sudo realm discover domaine.local
sudo realm join --user=Administrateur domaine.local
sudo realm permit --all            # ou : sudo realm permit 'Groupe Postes@domaine.local'
```

Les utilisateurs du domaine se connectent ensuite sur l'écran LightDM avec `prenom.nom@domaine.local`.

## Personnaliser un profil

Un profil est un fichier texte dans `apps/nos-cli/share/profiles/<id>.profile` (installé dans `/usr/share/nos/profiles/`) :

```ini
name=Mon service
description=Poste type du service comptabilité
tools=libreoffice thunderbird gnucash keepassxc     # identifiants du catalogue nos install
apt=paquet1 paquet2                                  # paquets APT supplémentaires
flatpak=org.exemple.App                               # applications Flatpak
optimizations=texte affiché par nos profile show
```

Le script d'optimisation associé est `scripts/profiles/<id>.sh` (exécuté en root). Les administrateurs de parc peuvent ainsi définir un profil « maison » et le déployer avec `nos profile apply mon-service` sur tous les postes.
