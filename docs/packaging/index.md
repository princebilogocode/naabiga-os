# Packaging et dépôts

## Paquets N-OS

Construits par `build/build-packages.sh` (dpkg-deb, sans debhelper, reproductibles). Version Debian dérivée de `VERSION` (`1.0.0-alpha.1` → `1.0.0~alpha.1`).

| Paquet | Contenu | Dépendances clés |
|---|---|---|
| `nos-cli` | `/usr/bin/nos`, `/usr/lib/nos/{lib,doctor,sdk,ai,scripts}`, catalogue, complétion, `/etc/profile.d/nos.sh` | bash, curl, git, tar, xz, unzip |
| `nos-branding` | logo, palette, fonds d'écran, Plymouth, GRUB, `/etc/nos-release` | plymouth, grub-common |
| `nos-desktop` | dconf Cinnamon, LightDM/Slick Greeter, lanceurs | cinnamon, lightdm, slick-greeter, nos-branding |
| `nos-base` | métapaquet de la plateforme de développement, sysctl, APT, service premier démarrage | nos-cli, nos-branding, openjdk-17, adb, python3, docker… |

```bash
make packages          # → build/out/packages/*.deb
sudo apt install ./build/out/packages/nos-cli_*.deb
```

## Formats

- **APT/.deb** : système et outils N-OS (dépôts du socle + dépôt N-OS).
- **Flatpak** : applications de bureau (Flathub activé au premier démarrage).
- **Snap** : non installé par défaut ([ADR-004](../architecture/decisions.md)).

## Dépôts officiels (phase RC)

```text
repo.naabiga.com/
├── dists/{stable,testing,unstable,nightly}
└── pool/
```

- Signature GPG (clé ICONEDOR), publiée dans `nos-branding` (`/usr/share/keyrings/naabiga-archive-keyring.gpg`).
- Outil : `aptly` ou `reprepro`, publication par GitHub Actions vers un stockage objet + CDN.
- Canal par défaut : `stable` ; `nos config set channel testing` pour les testeurs.

## Convention de versions

SemVer : `MAJEUR.MINEUR.CORRECTIF[-alpha.N|-beta.N|-rc.N]`. Tags Git `vX.Y.Z…`. Chaque tag déclenche la construction de l'ISO et des paquets (`.github/workflows/iso.yml`).

## Contrôles qualité d'un paquet

- `lintian` (Beta) ;
- installation/désinstallation propres dans un conteneur `ubuntu:24.04` (CI `packages`) ;
- scripts `postinst` idempotents et tolérants (`|| true` sur les services absents en chroot).
