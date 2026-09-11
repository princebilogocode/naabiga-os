# Construire l'ISO

## Prérequis

Une machine **N-OS** (ou un système à base Debian de génération « noble ») avec 30 Go libres et une bonne connexion (l'image télécharge ~4 Go de paquets ; utilisez un miroir proche).

```bash
sudo apt install live-build debootstrap xorriso squashfs-tools isolinux syslinux-common \
  grub-efi-amd64-bin grub-pc-bin mtools dosfstools dpkg-dev fakeroot imagemagick
```

## Construction

```bash
git clone https://github.com/princebilogocode/naabiga-os.git
cd naabiga-os
sudo make iso
```

Étapes de `build/build-iso.sh` :

1. `build/build-packages.sh` → `nos-cli`, `nos-branding`, `nos-desktop`, `nos-base` (`.deb`, injectés dans `iso/config/packages.chroot/`).
2. Copie de la configuration Calamares, du lanceur d'installation et des images Plymouth/GRUB générées.
3. `lb config` (`iso/auto/config`) : socle noble, amd64, ISO hybride, syslinux + GRUB EFI, Secure Boot.
4. `lb build` : bootstrap, installation des listes de paquets, hooks (branding, outils de dev, nettoyage), squashfs zstd, ISO.
5. `sha256sum`, signature GPG facultative (`NOS_GPG_KEY`).

Résultat : `build/out/naabiga-os-<version>-amd64.iso`, `.sha256`, `.log`.

## Options

| Variable | Rôle |
|---|---|
| `NOS_MIRROR` | miroir de paquets du socle (voir `iso/README.md`) ; un miroir `mirror.naabiga.com` est prévu en Beta |
| `NOS_SKIP_VSCODE=1`, `NOS_SKIP_FLUTTER=1`, `NOS_SKIP_NODE=1` | build de test plus rapide |
| `NOS_ARCH` | `amd64` (arm64 en Beta) |

## Tester

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cdrom build/out/naabiga-os-*.iso -boot d
# UEFI : -bios /usr/share/ovmf/OVMF.fd
```

Checklist QA : [Qualité](../qa/index.md).

## CI

Le workflow `.github/workflows/iso.yml` construit l'ISO à la demande (`workflow_dispatch`) et sur les tags `v*`, puis publie l'artefact et la release GitHub. Durée : 40 à 90 min.

## Dépannage

| Symptôme | Piste |
|---|---|
| `E: Unable to locate package cinnamon-desktop-environment` | `universe` absent : vérifiez `--archive-areas` dans `iso/auto/config` |
| Échec de téléchargement Flutter/Node dans le hook 0200 | réseau bloqué dans le chroot ; réessayez ou `NOS_SKIP_*=1` |
| ISO > 8 Go | retirez LibreOffice de `20-desktop.list.chroot` ou `NOS_SKIP_FLUTTER=1` |
| Pas d'écran de connexion | vérifiez `lightdm` et `50-nos-session.conf` dans le hook 0100 |
