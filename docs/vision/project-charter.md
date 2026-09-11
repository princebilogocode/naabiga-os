
# Naabiga OS (N-OS)
# Project Charter & Repository Blueprint
Version 1.0

**Dépôt officiel :** https://github.com/princebilogocode/naabiga-os

---

# Vision

Naabiga OS (abrégé **N-OS**) est une distribution Linux basée sur Ubuntu LTS, conçue pour offrir la meilleure expérience de développement possible.

Le projet privilégie :
- la stabilité ;
- la simplicité ;
- une excellente intégration des outils ;
- une expérience francophone par défaut.

La langue du système est **Français** lors de l'installation, avec possibilité d'ajouter d'autres langues.

---

# Objectifs

- Installation en moins de 20 minutes.
- Environnement de développement prêt en moins de 5 minutes après le premier démarrage.
- Cycle de publication aligné sur Ubuntu LTS.
- Documentation complète.
- Plateforme ouverte aux contributions.

---

# Architecture

```text
Debian
   │
Ubuntu LTS
   │
N-OS Core
   │
N-OS Desktop
   │
N-OS Developer Platform
   │
Applications N-OS
```

---

# Organisation du dépôt Git

```text
naabiga-os/
├── docs/
│   ├── vision/
│   ├── architecture/
│   ├── desktop/
│   ├── installer/
│   ├── packaging/
│   ├── security/
│   ├── qa/
│   ├── roadmap/
│   └── handbook/
├── branding/
├── build/
├── iso/
├── packages/
├── desktop/
├── installer/
├── apps/
│   ├── nos-center/
│   ├── nos-cli/
│   ├── nos-doctor/
│   ├── nos-sdk/
│   └── nos-ai/
├── scripts/
├── tests/
└── .github/
```

---

# Applications officielles

## N-OS Center

Centre logiciel moderne.

Fonctions :
- Installer des IDE
- Installer des SDK
- Installer des runtimes
- Gérer les mises à jour
- Gérer les extensions

## N-OS CLI

Commande unique :

```bash
nos doctor
nos install
nos update
nos repair
nos sdk
nos ai
```

## N-OS Doctor

Diagnostic complet :
- Android
- Flutter
- Java
- Docker
- Node.js
- Python
- Git
- Variables d'environnement

Réparation automatique lorsque cela est possible.

## N-OS SDK Manager

Gestion de plusieurs versions :
- Flutter
- Java
- Node.js
- Android SDK
- Dart

---

# Logiciels préinstallés

- Android Studio
- VS Code
- Git
- Flutter
- Dart
- Java 17 LTS
- Android SDK
- adb
- fastboot
- Node.js LTS
- Python
- Docker
- Docker Compose
- Playwright
- Claude Code
- OpenCode
- Ollama
- Firefox

Les composants propriétaires (ex. Google Chrome) pourront être proposés durant l'installation ou via N-OS Center selon leurs conditions de distribution.

---

# Interface

- Cinnamon
- Thème N-OS
- Icônes N-OS
- Plymouth personnalisé
- GRUB personnalisé
- Fonds d'écran N-OS

---

# Dépôts

- stable
- testing
- unstable
- nightly

---

# CI/CD

Chaque commit :
1. Compilation
2. Tests
3. Analyse qualité
4. Construction ISO
5. Publication artefacts

---

# Documentation

Toute la documentation est en Markdown et publiée avec MkDocs Material.

---

# Règles de développement

- GitFlow
- Conventional Commits
- Semantic Versioning
- Pull Requests obligatoires
- Revue de code obligatoire

---

# Roadmap

## Alpha
- Branding
- ISO minimale
- Installateur

## Beta
- N-OS Center
- N-OS CLI
- N-OS Doctor

## RC
- Dépôts officiels
- Documentation
- Tests matériels

## 1.0 LTS
- Première version stable

---

# Philosophie

N-OS ne cherche pas à modifier Ubuntu en profondeur.

Le projet ajoute une couche d'outils, de qualité et d'intégration afin que chaque développeur puisse travailler immédiatement après l'installation du système.
