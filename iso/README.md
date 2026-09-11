# iso/ — construction de l'image Naabiga OS

Configuration [live-build](https://live-team.pages.debian.net/live-manual/) pour produire l'ISO hybride de Naabiga OS (BIOS + UEFI, Secure Boot) : socle LTS « noble », bureau **Cinnamon**, installateur **Calamares**.

```text
iso/
├── auto/config                 Paramètres lb config (noble, amd64, iso-hybrid, syslinux+grub-efi)
├── auto/build, auto/clean
├── config/package-lists/       10-live, 20-desktop, 30-dev, 40-installer, 50-nos
├── config/hooks/normal/        0100 branding, 0200 outils dev (VS Code, Flutter, Node, IA), 0900 nettoyage
├── config/includes.chroot/     Fichiers copiés tels quels dans le système (skel, /usr/share/nos)
└── config/packages.chroot/     (généré) paquets .deb N-OS injectés par build/build-iso.sh
```

## Construire

Sur une machine N-OS ou tout système à base Debian de génération « noble » (VM ou conteneur privilégié) :

```bash
sudo apt install live-build debootstrap xorriso squashfs-tools isolinux syslinux-common grub-efi-amd64-bin grub-pc-bin mtools dosfstools dpkg-dev fakeroot
sudo make iso
# → build/out/naabiga-os-<version>-amd64.iso + .sha256
```

Variables utiles :

| Variable | Rôle | Défaut |
|---|---|---|
| `NOS_MIRROR` | Miroir de paquets du socle (choisir un miroir proche : `http://bf.archive.ubuntu.com/ubuntu/`, `http://mirror.ihost.ci/ubuntu/`…) | archive.ubuntu.com |
| `NOS_ARCH` | Architecture | amd64 |
| `NOS_SKIP_VSCODE`, `NOS_SKIP_FLUTTER`, `NOS_SKIP_NODE` | `1` pour ignorer un outil lourd (build rapide de test) | 0 |
| `NOS_GPG_KEY` | Identifiant de clé pour signer le `SHA256SUMS` | — |

## Tester

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom build/out/naabiga-os-*.iso -boot d
# UEFI : ajouter -bios /usr/share/ovmf/OVMF.fd
```

Session live : utilisateur `naabiga`, sans mot de passe, clavier français, fuseau Africa/Ouagadougou.

## Taille attendue

Environ 5 à 6 Go avec Flutter, Node.js, VS Code, OpenJDK 17, Docker, LibreOffice. Android Studio n'est **pas** dans l'image (3 Go supplémentaires) : `nos install android-studio` après installation.
