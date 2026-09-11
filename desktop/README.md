# N-OS Desktop — personnalisation Cinnamon

Ce dossier contient tout ce qui définit l'expérience de bureau de Naabiga OS (paquets `nos-desktop` et `nos-branding`).

| Dossier | Contenu | Installé dans |
|---|---|---|
| `dconf/` | Réglages Cinnamon par défaut (thème, panneau, favoris, raccourcis, terminal) | `/etc/dconf/db/local.d/`, `/etc/dconf/profile/user` |
| `cinnamon/` | LightDM + Slick Greeter (écran de connexion), lanceurs `.desktop` N-OS Center et Doctor, autostart de l'assistant de bienvenue | `/etc/lightdm/`, `/usr/share/applications/`, `/etc/xdg/autostart/` |
| `plymouth/` | Thème de démarrage (script Plymouth, images) | `/usr/share/plymouth/themes/naabiga/` |
| `grub/` | Thème GRUB (`theme.txt`, images) | `/boot/grub/themes/naabiga/` |
| `gtk-theme/`, `icons/` | Réservés au thème GTK et au pack d'icônes N-OS (phase Beta). Alpha : Yaru-red-dark + Papirus-Dark | — |

## Choix Alpha

- **Thème GTK** : `Yaru-red-dark` (paquet `yaru-theme-gtk`, accent rouge proche du rouge NAABIGA) en attendant le thème N-OS.
- **Icônes** : `Papirus-Dark`.
- **Polices** : Inter (texte), Poppins Bold (titres), JetBrains Mono (terminal).
- **Panneau** : bas, 40 px, menu + liste de fenêtres groupées + zone système.
- **Favoris** : Nemo, Terminal, VS Code, Android Studio, N-OS Center, Firefox, Paramètres.
- **Raccourcis** : `Ctrl+Alt+T` terminal, `Super+E` fichiers, `Super+D` N-OS Doctor.
- **Terminal** : palette 16 couleurs dérivée de la charte (rouge `#D62828`, vert `#198754`, or `#D4AF37`).

## Images générées

Les PNG de Plymouth (`progress-bg.png`, `progress-fg.png`) et de GRUB (`background.png`, `select_*.png`, `terminal_box_*.png`, `scrollbar_thumb_*.png`) sont générés à la construction par `build/gen-assets.sh` à partir de la palette (`branding/palette/naabiga.json`) et du logo, pour ne pas versionner de binaires.

## Tester

```bash
# Appliquer les réglages dconf sur une machine Cinnamon
sudo cp desktop/dconf/00-naabiga-defaults /etc/dconf/db/local.d/
sudo cp desktop/dconf/profile-user /etc/dconf/profile/user
sudo dconf update
# Se déconnecter / reconnecter
```
