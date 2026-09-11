# Bureau N-OS (Cinnamon)

Le bureau est défini par les paquets `nos-desktop` (réglages) et `nos-branding` (identité). Sources : `desktop/` et `branding/`.

## Expérience par défaut

| Élément | Choix Alpha |
|---|---|
| Environnement | Cinnamon (session `cinnamon`), LightDM + Slick Greeter |
| Thème GTK / fenêtres | Yaru-red-dark |
| Icônes | Papirus-Dark |
| Polices | Inter 10 (interface), Poppins Bold (titres), JetBrains Mono 11 (terminal) |
| Fond d'écran | `naabiga-default.svg` (noir, chevron or/rouge/vert) |
| Panneau | bas, 40 px |
| Favoris | Fichiers, Terminal, VS Code, Android Studio, N-OS Center, Firefox, Paramètres |
| Raccourcis | `Ctrl+Alt+T` terminal, `Super+E` fichiers, `Super+D` N-OS Doctor |
| Terminal | fond `#111111`, palette NAABIGA 16 couleurs |
| Démarrage | Plymouth « naabiga » (logo, barre or → rouge), GRUB thème « naabiga » |
| Connexion | fond `naabiga-login.svg`, logo, nom d'hôte, horloge 24 h |

## Fichiers

- `desktop/dconf/00-naabiga-defaults` : base dconf `local` ; toute clé peut être surchargée par l'utilisateur.
- `desktop/cinnamon/99-naabiga.conf`, `99-naabiga-greeter.conf` : LightDM et Slick Greeter.
- `desktop/plymouth/naabiga.{plymouth,script}` : thème de démarrage (images générées par `build/gen-assets.sh`).
- `desktop/grub/theme.txt` : thème GRUB.
- `desktop/cinnamon/*.desktop` : lanceurs N-OS Center et N-OS Doctor.

## Personnaliser

Les réglages sont des valeurs par défaut : l'utilisateur garde le contrôle via Paramètres système. Pour restaurer les défauts N-OS : `dconf reset -f /org/cinnamon/`.

## Roadmap

- **Beta** : thème GTK « Naabiga » (clair et sombre), pack d'icônes N-OS, curseurs, sons, écran de bienvenue au premier lancement (choix IDE, SDK, IA).
- **RC** : variantes de fonds d'écran, mode clair par défaut pour les salles de cours.
