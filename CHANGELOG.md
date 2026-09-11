# Changelog

Toutes les modifications notables de ce projet sont documentées ici.
Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) : Versionnage : [SemVer](https://semver.org/lang/fr/).

## [Unreleased]

## [1.0.0-alpha.2] - 2026-09-11

### Added
- `nos welcome` : assistant de premier démarrage (whiptail ou non interactif) : profils, IDE, assistants IA, diagnostic ; lancé automatiquement à la première session (`/etc/xdg/autostart/nos-welcome.desktop`).
- `nos update --check` : compare la version installée avec la dernière version publiée (code de retour 10 si une mise à jour existe).
- `nos info --json` pour N-OS Center.
- Doctor : vérifications `go`, `rust`, `php`, `education` et `administration` (bloquantes seulement si le profil est appliqué).
- Site officiel https://naabiga.com référencé partout (README, aide, motd, os-release, installateur, rapport Doctor).
- Contrôle de style `scripts/check-style.sh` (pas de tirets cadratins) dans `make lint` et la CI.
- Labels, jalons (Alpha, Beta, RC, 1.0 LTS) et 16 issues de roadmap sur GitHub, dont des missions étudiantes.

### Changed
- Positionnement : N-OS est le premier système d'exploitation conçu par des Burkinabè, pour les Burkinabè et pour l'Afrique ; plus aucune mention publique du socle.
- Textes sans tirets cadratins ni demi-cadratins.

## [1.0.0-alpha.1] - 2026-09-11

### Added
- Structure officielle du dépôt conforme au Project Charter.
- Documentation fondatrice (cahier des charges, spécification, charte, blueprint, SAD) publiée avec MkDocs Material.
- `nos` CLI (Bash) : `doctor`, `install`, `remove`, `update`, `repair`, `sdk`, `ai`, `info`, `version`, `config`.
- N-OS Doctor (17 vérifications) : Git, Java, Android SDK, adb, Flutter, Dart, Node.js, Python, Docker, PATH, variables d'environnement ; réparation automatique ; export JSON et HTML.
- N-OS SDK Manager : gestion multi-versions de Flutter, Java, Node.js et Android SDK.
- N-OS AI Hub : installation de Claude Code, Gemini CLI, Ollama, Aider, OpenCode, Continue.
- Catalogue d'outils `nos install` (68 entrées : IDE, langages, bases de données, navigateurs, IA, bureautique, enseignement, administration).
- `nos profile` : profils d'usage **dev**, **bureautique** (LibreOffice fr, polices Office, impression/scan, PDF/OCR), **education** (LaTeX, Jupyter, R, Octave, GeoGebra, Zotero, Veyon, mode salle de TP) et **administration** (durcissement, sauvegardes, ClamAV, Active Directory, inventaire GLPI, USB lecture seule) avec optimisations dédiées.
- Vérification Doctor `office` (LibreOffice, français, impression).
- Politique zéro secret : `.gitignore` renforcé, `scripts/check-secrets.sh`, hook pre-commit, job CI + Gitleaks.
- Configuration live-build pour l'ISO N-OS (socle LTS + Cinnamon), hooks de branding et d'optimisation.
- Configuration Calamares (français par défaut, LUKS proposé, branding N-OS).
- Personnalisation Cinnamon (dconf), Plymouth, GRUB, thème et palette NAABIGA.
- Paquets .deb : `nos-base`, `nos-branding`, `nos-cli`, `nos-desktop`.
- Scripts d'optimisation : ZRAM, TRIM, SSD, Docker, Flutter, Android Studio, démarrage rapide.
- Squelette Flutter Desktop de N-OS Center.
- CI GitHub Actions : lint (shellcheck), tests (bats), build docs, build paquets, build ISO manuel.
- Tests bats pour la CLI et Doctor.

[Unreleased]: https://github.com/princebilogocode/naabiga-os/compare/v1.0.0-alpha.2...HEAD
[1.0.0-alpha.2]: https://github.com/princebilogocode/naabiga-os/compare/v1.0.0-alpha.1...v1.0.0-alpha.2
[1.0.0-alpha.1]: https://github.com/princebilogocode/naabiga-os/releases/tag/v1.0.0-alpha.1
