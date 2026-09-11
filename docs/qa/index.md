# Qualité (QA)

## Tests automatiques (CI, chaque PR)

| Test | Commande | Outil |
|---|---|---|
| Lint Bash | `make lint` | shellcheck |
| Unitaires CLI, Doctor, SDK, AI | `make test-unit` | bats (mode `NOS_DRY_RUN=1`) |
| Intégration (installation DESTDIR, cohérence du dépôt, build des .deb) | `make test-integration` | bash, dpkg-deb |
| Documentation | `mkdocs build --strict` | MkDocs |
| Paquets | installation dans `ubuntu:24.04` | Docker (CI) |
| ISO | `workflow_dispatch` / tags | live-build (CI) |

## Checklist release (manuelle, bloquante)

Réalisée par l'équipe QA sur l'ISO candidate, résultats consignés dans l'issue de release.

### Démarrage et installation

- [ ] Démarrage BIOS (QEMU, PC ancien)
- [ ] Démarrage UEFI + Secure Boot (QEMU OVMF, PC récent)
- [ ] Session live : clavier fr, langue fr, réseau, son
- [ ] Installation « effacer le disque » ext4
- [ ] Installation avec LUKS (mot de passe demandé dans Plymouth)
- [ ] Dual-boot avec Windows (GRUB liste Windows)
- [ ] Redémarrage : Plymouth N-OS, GRUB N-OS, écran de connexion N-OS

### Matériel

- [ ] Intel intégré
- [ ] AMD
- [ ] NVIDIA (pilote libre puis `ubuntu-drivers install`)
- [ ] Wi-Fi, Bluetooth, webcam, veille/reprise

### Plateforme de développement

- [ ] `nos doctor` **sans échec** au premier démarrage (critère de réussite du projet)
- [ ] `flutter doctor` OK pour Linux et Android (après `nos sdk install android`)
- [ ] `flutter create demo && cd demo && flutter build linux`
- [ ] `nos install android-studio` puis lancement, émulateur avec KVM
- [ ] `docker run hello-world` sans sudo (après reconnexion)
- [ ] `javac -version` = 17, `gradle --version`, `mvn --version`
- [ ] `node --version` ≥ 20, `npm i -g pnpm`
- [ ] `python3 -m venv .venv`, `pip install requests`
- [ ] `npx playwright test` (projet exemple)
- [ ] `nos ai install ollama && ollama run qwen2.5-coder:1.5b`

### Performance

- [ ] Démarrage < 30 s sur SSD (mesure `systemd-analyze`)
- [ ] ZRAM actif (`zramctl`), `fstrim.timer` actif
- [ ] Mémoire au repos < 1,2 Go

### Régression

- [ ] `nos update` complet sans erreur
- [ ] Mise à niveau depuis la version précédente (Beta+)

## Bugs

Template « Bug » avec `nos doctor --json` et `nos info` joints. Étiquettes : `bug`, `regression`, `hardware`, `known-issue`.
