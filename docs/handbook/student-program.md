# Programme étudiant : Université Aube Nouvelle (Bobo-Dioulasso)

Naabiga OS est développé par ICONEDOR **en collaboration avec les étudiants de l'U-AUBEN**. Ce programme transforme le projet en terrain d'apprentissage réel : Linux, packaging, CLI, CI/CD, QA, documentation, design.

## Objectifs pédagogiques

- Contribuer à un logiciel libre en production, avec revue de code et intégration continue.
- Maîtriser Git (GitFlow), les Conventional Commits et les Pull Requests.
- Comprendre une distribution Linux de l'intérieur : paquets, systemd, installateur, image live.
- Travailler en équipe pluridisciplinaire avec des professionnels.

## Parcours

| Niveau | Durée | Missions types | Compétences validées |
|---|---|---|---|
| **Découverte** | 2 semaines | Installer N-OS en VM, lancer `nos doctor`, corriger une page de doc, tester un scénario QA | Git, Markdown, issue GitHub |
| **Contributeur** | 1 à 2 mois | Ajouter une vérification Doctor, un outil au catalogue, un fond d'écran, un test bats | Bash, shellcheck, tests |
| **Ingénieur** | Semestre / stage | Module Calamares, hook ISO, paquet .deb, page N-OS Center, portage Rust | Packaging, Flutter, Rust, CI |

## Comment démarrer

1. Créez un compte GitHub et lisez `CONTRIBUTING.md`.
2. Installez N-OS (ou la CLI) et lancez `nos doctor`.
3. Prenez une issue étiquetée [`étudiant`](https://github.com/princebilogocode/naabiga-os/labels/%C3%A9tudiant) ou [`good first issue`](https://github.com/princebilogocode/naabiga-os/labels/good%20first%20issue).
4. Travaillez sur une branche `feature/…`, ouvrez une PR, répondez à la revue.
5. Une fois fusionné : ajoutez votre nom à `AUTHORS.md`.

## Encadrement

- Un référent ICONEDOR par équipe ([Équipes](teams.md)).
- Un enseignant référent U-AUBEN pour la validation académique (stages, projets tutorés, mémoires).
- Séances hebdomadaires en présentiel à Bobo-Dioulasso et suivi asynchrone sur GitHub.

## Sujets de mémoire proposés

- Gestion de versions de SDK dans un système Linux : conception de `nos-core` en Rust.
- Optimisation d'une distribution pour matériel modeste (ZRAM, services, démarrage).
- Dépôt APT signé et serveur de mise à jour OTA pour une distribution dérivée.
- Expérience utilisateur d'un centre logiciel (N-OS Center) : étude et prototypage Flutter.
- Sécurité par défaut d'un poste de développeur (UFW, AppArmor, LUKS, Secure Boot).

## Reconnaissance

Chaque contribution fusionnée est visible publiquement. Les contributeurs réguliers sont cités dans les notes de version et peuvent obtenir une attestation ICONEDOR.
