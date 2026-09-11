# Équipes

Organisation issue du cahier des charges (§13) et de la spécification (§10). Chaque équipe a un responsable ICONEDOR et des étudiants U-AUBEN.

| Équipe | Périmètre | Dossiers | Compétences |
|---|---|---|---|
| **Distribution** | ISO, noyau, installateur, paquets système | `iso/`, `installer/`, `packages/`, `build/` | live-build, Debian packaging, systemd, Calamares |
| **Applications** | N-OS CLI, Doctor, SDK Manager, AI Hub, N-OS Center | `apps/`, `scripts/` | Bash, Rust (Beta), Flutter |
| **UX/UI** | Logo, thème, icônes, fonds d'écran, Plymouth, GRUB, écran de connexion | `branding/`, `desktop/` | Design, GTK, SVG |
| **Infrastructure** | Dépôts APT, serveur ISO, CDN, CI/CD, serveur de mise à jour | `.github/`, `docs/packaging/` | GitHub Actions, reprepro/aptly, Nginx |
| **QA** | Tests automatiques, tests matériels, régression | `tests/`, `docs/qa/` | bats, QEMU, checklists |
| **Documentation** | Guides, wiki, API, traductions | `docs/` | Markdown, MkDocs |

## Rituels

- **Stand-up hebdomadaire** par équipe (15 min).
- **Revue de sprint** toutes les deux semaines, démo sur l'ISO du jour.
- **Revue de code** : toute PR est relue par un membre d'une autre équipe au moins une fois par sprint (apprentissage croisé).

## Responsabilités transverses

- Le responsable QA peut bloquer une release.
- Le responsable Distribution signe les ISO (`NOS_GPG_KEY`).
- Le responsable Documentation valide que chaque fonctionnalité livrée est documentée.
