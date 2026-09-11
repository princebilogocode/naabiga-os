
# Naabiga OS (NOS)
# Software Architecture Document (SAD)
Version 0.1

Auteur : ICONEDOR
Statut : Brouillon fondateur

---

# 1. Objectif

Ce document définit l'architecture logicielle officielle de Naabiga OS (NOS).

Il constitue la référence technique utilisée par toutes les équipes de développement.

---

# 2. Principes d'architecture

## Ne jamais réinventer la roue

NOS s'appuie sur un socle Linux LTS éprouvé.

Le projet se concentre sur :

- l'expérience développeur ;
- l'intégration des outils ;
- les performances ;
- la stabilité ;
- la simplicité.

---

# 3. Architecture globale

```text
Noyau Linux
    │
Socle LTS
    │
NOS Core
    │
NOS Desktop
    │
NOS Developer Platform
    │
Applications NOS
```

---

# 4. Composants

## NOS Core

Responsabilités :

- personnalisation du socle
- configuration système
- paquets NOS
- branding
- politiques de sécurité
- mises à jour

Livrables :

- nos-base
- nos-system
- nos-branding
- nos-config

---

## NOS Desktop

Basé sur Cinnamon.

Personnalisations :

- thème GTK
- icônes
- curseurs
- Plymouth
- écran de connexion
- fonds d'écran
- paramètres par défaut

---

## NOS Developer Platform

Objectif :

Un environnement de développement prêt immédiatement.

Comprend :

- Java
- Flutter
- Dart
- Android SDK
- adb
- fastboot
- Node.js
- Python
- Docker
- Git

---

# 5. Applications officielles

## NOS Center

Gestionnaire graphique.

Fonctions :

- installer des outils
- gérer les SDK
- gérer les mises à jour
- gérer les extensions

Technologie recommandée :

Flutter Desktop.

---

## NOS Doctor

Commande :

```bash
nos doctor
```

Fonctions :

- diagnostic
- réparation
- génération d'un rapport
- export JSON

---

## NOS CLI

Commande unique :

```bash
nos
```

Sous-commandes :

- doctor
- install
- remove
- update
- repair
- sdk
- info
- version

---

## NOS SDK Manager

Gestion des versions de :

- Flutter
- Java
- Node
- Android SDK
- Kotlin

---

# 6. Arborescence Git

```text
github.com/iconedor

nos-core
nos-cli
nos-center
nos-doctor
nos-sdk
nos-installer
nos-branding
nos-docs
nos-packages
nos-build
```

---

# 7. Pipeline CI/CD

À chaque commit :

1. Build
2. Tests
3. Analyse qualité
4. Création des paquets
5. Génération ISO
6. Publication dépôt de test

Pour chaque release :

- signature GPG
- génération SHA256
- publication ISO

---

# 8. Dépôts APT

Proposition :

```text
repo.naabiga.com

stable
testing
unstable
nightly
```

---

# 9. Qualité

Tests obligatoires :

- démarrage
- installation
- mises à jour
- Flutter
- Android Studio
- Docker
- compilation Java
- compilation Flutter
- Playwright

---

# 10. Sécurité

- Secure Boot
- UFW activé
- AppArmor
- paquets signés
- mises à jour automatiques

---

# 11. Normes de développement

Langages recommandés :

- Dart (applications)
- Bash (scripts)
- Python (automatisation)
- Rust (outils système critiques)
- C/C++ uniquement si nécessaire

Conventions :

- GitFlow
- Conventional Commits
- Semantic Versioning
- Documentation Markdown

---

# 12. Roadmap technique

## Alpha

- Branding
- ISO minimale
- Installateur

## Beta

- NOS CLI
- NOS Doctor
- NOS Center

## RC

- Dépôts officiels
- Documentation
- Tests matériels

## Version 1.0 LTS

- Support entreprise
- Documentation complète
- Infrastructure mondiale

---

# 13. Décisions d'architecture

- Base : socle Linux LTS (génération noble, support 5 ans)
- Bureau : Cinnamon
- Installateur : Calamares
- Paquets : APT + Flatpak
- Build : GitHub Actions ou GitLab CI
- Documentation : MkDocs Material
- Applications : Flutter Desktop
- Outils système : Rust + Bash

---

# 14. Vision long terme

Construire un écosystème complet :

- Naabiga OS Community
- Naabiga OS Enterprise
- NOS Cloud
- NOS SDK
- NOS AI Suite
- NOS Device Manager
- NOS Update Server
- NOS Developer Portal

Ce document est la référence d'architecture initiale et sera enrichi au fil des versions.
