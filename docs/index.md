# Naabiga OS

![Naabiga OS](assets/logo.png){ width="140" }

**Naabiga OS (N-OS)** est une distribution Linux basée sur Ubuntu 24.04 LTS, conçue pour qu'un développeur soit **prêt à coder en moins de 5 minutes** après l'installation.

> Build Faster. Create Smarter.

Développée par **ICONEDOR** (Burkina Faso) en collaboration avec les étudiants de **l'Université Aube Nouvelle (U-AUBEN), Bobo-Dioulasso**, dans l'écosystème **NAABIGA**.

## Par où commencer ?

| Vous êtes… | Lisez |
|---|---|
| Utilisateur ou étudiant | [Démarrer](handbook/getting-started.md), [N-OS Doctor](handbook/nos-doctor.md) |
| Bureautique, enseignement supérieur, administration | [Profils d'usage](handbook/profiles.md) |
| Contributeur | [Équipes](handbook/teams.md), [Programme étudiant](handbook/student-program.md), `CONTRIBUTING.md` |
| Équipe Distribution | [Construire l'ISO](handbook/build-iso.md), [Installateur](installer/index.md), [Packaging](packaging/index.md) |
| Équipe Applications | [N-OS CLI](handbook/nos-cli.md), [SDK Manager](handbook/nos-sdk.md), [AI Hub](handbook/nos-ai.md) |
| Direction / partenaires | [Cahier des charges](vision/cahier-des-charges.md), [Charte du projet](vision/project-charter.md), [Roadmap](roadmap/roadmap.md) |

## L'essentiel en trois commandes

```bash
nos doctor            # tout va bien ?
nos doctor --repair   # sinon, on répare
nos install flutter   # et on installe ce qui manque
```

## Architecture

```text
Debian → Ubuntu 24.04 LTS → N-OS Core → N-OS Desktop → N-OS Developer Platform → Applications N-OS
```

Décisions : Cinnamon, Calamares, APT + Flatpak, MkDocs Material, Flutter Desktop (N-OS Center), Bash puis Rust (outils système). Détails dans [le SAD](architecture/software-architecture-document.md) et [les ADR](architecture/decisions.md).
