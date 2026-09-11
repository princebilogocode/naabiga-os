# Guide de contribution

Merci de vouloir contribuer à Naabiga OS. Ce guide s'adresse à tous, en particulier aux étudiants de l'Université Aube Nouvelle (Bobo-Dioulasso) qui rejoignent le projet.

## 1. Prérequis

- Un compte GitHub.
- Git installé (`sudo apt install git`).
- Pour la CLI et les tests : Bash 5, `shellcheck`, `bats`.
- Pour l'ISO : Ubuntu 24.04, `live-build`, `debootstrap`, `xorriso`, `squashfs-tools`.
- Pour la documentation : Python 3 et `pip install mkdocs-material`.

## 2. Workflow Git (GitFlow simplifié)

| Branche | Rôle |
|---|---|
| `main` | Versions publiées uniquement (taguées) |
| `develop` | Intégration continue, base de toutes les fonctionnalités |
| `feature/<sujet>` | Une fonctionnalité ou correction |
| `release/<version>` | Stabilisation avant publication |
| `hotfix/<sujet>` | Correctif urgent sur `main` |

```bash
git clone https://github.com/princebilogocode/naabiga-os.git
cd naabiga-os
git checkout develop
git checkout -b feature/nos-doctor-check-go
# ... travail ...
make lint test
git push -u origin feature/nos-doctor-check-go
# ouvrir une Pull Request vers develop
```

## 3. Conventional Commits

Format : `<type>(<portée>): <description courte>`

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `chore`, `perf`.

Portées courantes : `cli`, `doctor`, `sdk`, `ai`, `center`, `iso`, `installer`, `desktop`, `packages`, `docs`, `ci`.

Exemples :

```text
feat(doctor): ajouter la vérification de Go
fix(iso): corriger le hook de nettoyage APT
docs(handbook): guide de construction de l'ISO
```

## 4. Pull Requests

- Une PR = un sujet.
- La CI doit être verte (lint, tests, build docs).
- Au moins **une revue approuvée** est obligatoire.
- Remplissez le template de PR.
- Les PR vers `main` ne viennent que de `release/*` ou `hotfix/*`.

## 5. Normes de code

- **Bash** : `#!/usr/bin/env bash`, `set -euo pipefail`, passer `shellcheck` sans avertissement, fonctions préfixées par le module (`doctor_check_java`).
- **Dart/Flutter** : `dart format`, `flutter analyze` sans erreur.
- **Python** : `ruff`, typage.
- **Documentation** : Markdown, en français, publié via MkDocs Material.
- Indentation : 2 espaces (voir `.editorconfig`).

## 6. Tests

```bash
make lint   # shellcheck sur tous les scripts
make test   # bats (unitaires) + tests d'intégration
```

Toute nouvelle vérification de `nos doctor` ou nouvelle commande `nos` doit être accompagnée d'un test dans `tests/`.

## 7. Où contribuer ?

- **Débutant** : documentation, traductions, fonds d'écran, icônes, tests manuels sur du matériel.
- **Intermédiaire** : nouvelles vérifications Doctor, nouveaux outils dans le catalogue `nos install`.
- **Avancé** : ISO/live-build, Calamares, paquets .deb, N-OS Center (Flutter), portage Rust.

Les issues étiquetées `good first issue` et `étudiant` sont réservées aux nouveaux contributeurs.

## 8. Aucun secret dans le code

Ne commitez jamais de clé API, jeton, mot de passe, clé privée, keystore ou fichier de credentials. Installez le hook qui le vérifie avant chaque commit :

```bash
make hooks
```

Les tests et la CI n'ont besoin d'aucun secret. Si une fonctionnalité en nécessite un, lisez-le depuis une variable d'environnement et documentez-la.

## 9. Signalement de bugs et sécurité

- Bugs : ouvrez une issue avec le template « Bug ».
- Vulnérabilités : ne créez pas d'issue publique, voir [SECURITY.md](SECURITY.md).

## 10. Licence

En contribuant, vous acceptez que votre code soit publié sous licence GPL-3.0.
