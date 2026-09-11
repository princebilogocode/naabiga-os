# installer/ — Calamares

Naabiga OS utilise [Calamares](https://calamares.io/) comme installateur graphique (décision d'architecture, voir `docs/architecture/software-architecture-document.md` §13).

```text
installer/calamares/
├── settings.conf                 Séquence des modules (welcome → locale → keyboard → partition → users → summary → install → finished)
├── modules/
│   ├── welcome.conf              Prérequis : 25 Go, 2 Go RAM, secteur ; liens support/notes de version
│   ├── locale.conf               Fuseau par défaut Africa/Ouagadougou, géolocalisation KDE
│   ├── keyboard.conf             Disposition française par défaut
│   ├── partition.conf            ext4 par défaut, btrfs/xfs, LUKS2 proposé, GPT/MBR
│   ├── users.conf                Groupes dev (docker, kvm, dialout, plugdev), sudo, pas de root
│   ├── packages.conf             Suppression des paquets live et de Calamares après installation
│   ├── displaymanager.conf       LightDM + session Cinnamon
│   ├── shellprocess-nos.conf     Finalisation N-OS (premier démarrage, dconf, initramfs)
│   └── finished.conf             Redémarrage proposé
└── branding/naabiga/
    ├── branding.desc             Nom, version, URL, couleurs NAABIGA (noir, or, rouge)
    └── show.qml                  Diaporama pendant l'installation (5 diapositives)
```

## Déploiement dans l'image

Le hook `iso/config/hooks/normal/0100-nos-branding.hook.chroot` et le paquet `nos-desktop` (phase Beta) copient :

- `settings.conf` → `/etc/calamares/settings.conf`
- `modules/*.conf` → `/etc/calamares/modules/`
- `branding/naabiga/` → `/etc/calamares/branding/naabiga/` (avec `logo.png` et `welcome.png` générés depuis `branding/logo/`).

## Tester sans reconstruire l'ISO

Sur une session live N-OS (ou une VM avec `calamares` installé) :

```bash
sudo cp -r installer/calamares/* /etc/calamares/
sudo cp branding/logo/naabiga-os-logo.png /etc/calamares/branding/naabiga/logo.png
sudo cp branding/logo/naabiga-os-logo.png /etc/calamares/branding/naabiga/welcome.png
sudo calamares -d
```

## Langue

L'installateur démarre en français (`locales=fr_FR.UTF-8` dans les options de démarrage live). Les autres langues restent sélectionnables dans l'écran d'accueil.
