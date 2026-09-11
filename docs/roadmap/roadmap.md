# Roadmap

Synthèse des feuilles de route du cahier des charges, de la spécification et du blueprint, avec l'état réel du dépôt.

## Alpha — « Bobo » (en cours)

| Livrable | État |
|---|---|
| Structure du dépôt, gouvernance (GitFlow, Conventional Commits, SemVer) | ✅ |
| Branding : logo, palette, fonds d'écran, Plymouth, GRUB, écran de connexion | ✅ (images générées au build ; thème GTK dédié en Beta) |
| N-OS CLI, Doctor, SDK Manager, AI Hub | ✅ Bash, tests bats |
| Catalogue `nos install` (68 outils) | ✅ |
| Profils bureautique, enseignement supérieur, administration (`nos profile`) | ✅ |
| Politique zéro secret (scanner, hook pre-commit, Gitleaks en CI) | ✅ |
| Configuration ISO live-build (socle LTS + Cinnamon) | ✅ à valider par un build complet |
| Installateur Calamares (fr, LUKS, branding) | ✅ à valider sur l'ISO |
| Paquets .deb (nos-cli, nos-branding, nos-desktop, nos-base) | ✅ |
| Optimisations (ZRAM, TRIM, SSD, boot, Docker, Flutter, Android Studio) | ✅ |
| Sécurité par défaut (UFW, AppArmor, unattended-upgrades) | ✅ |
| CI : lint, tests, docs, paquets, ISO manuel | ✅ |
| Documentation MkDocs | ✅ |
| **Première ISO Alpha publiée** | ⏳ prochaine étape |

## Beta

- N-OS Center packagé (.deb), notifications de mises à jour.
- `nos-core` en Rust : téléchargements, SHA256, versions ; CLI Bash en frontal.
- Thème GTK et pack d'icônes N-OS ; écran de bienvenue au premier lancement.
- Dépôt APT `testing` signé ; `nos update` via le dépôt N-OS.
- Tests matériels (Intel, AMD, NVIDIA), dual-boot, LUKS.
- Support arm64 (expérimental).

## RC

- Dépôts `stable`, `testing`, `unstable`, `nightly` sur `repo.naabiga.org`.
- Site officiel (téléchargement, docs, blog, roadmap, forum, support).
- Documentation complète FR + EN.
- Tests de régression automatisés en VM (QEMU dans la CI).

## 1.0 LTS

- Publication publique, support long terme de 5 ans.
- Édition Enterprise : gestion de parc, déploiement en entreprise, support professionnel.
- Adoption dans les universités et écoles (U-AUBEN en pilote).

## Vision 2026–2030

Naabiga OS Community et Enterprise, NOS Cloud, NOS AI Suite, NOS Device Manager, NOS Build Farm, NOS Update Server, NOS Developer Portal : faire de N-OS la plateforme de développement de référence en Afrique, portée par ICONEDOR et sa communauté.
