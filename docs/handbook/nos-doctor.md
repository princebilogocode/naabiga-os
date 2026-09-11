# N-OS Doctor

`nos doctor` vérifie que l'environnement de développement est complet et cohérent, propose une correction pour chaque problème et peut réparer automatiquement.

```bash
nos doctor                 # rapport texte
nos doctor --repair        # réparation automatique puis nouveau contrôle
nos doctor --json          # pour N-OS Center, la CI, le support
nos doctor --export r.html # rapport HTML aux couleurs NAABIGA
nos doctor flutter         # une seule vérification
nos doctor --list          # vérifications disponibles
```

## Vérifications

| ID | Catégorie | Vérifie | Réparation automatique |
|---|---|---|---|
| `git` | Base | git présent, identité configurée | installe git |
| `java` | Android & Flutter | JDK 17/21, `javac`, `JAVA_HOME` | `nos sdk install java 17` + `use` |
| `android_sdk` | Android & Flutter | SDK trouvé, composants, licences, `ANDROID_HOME` | `nos sdk install android` |
| `adb` | Android & Flutter | adb, fastboot, règles udev | installe `adb fastboot` |
| `flutter` | Android & Flutter | flutter présent, dossier inscriptible, cache Dart | `flutter precache` ou install |
| `dart` | Android & Flutter | dart dans le PATH | via Flutter |
| `go` | Langages | go présent, `~/go/bin` dans le PATH (optionnel) | installe Go |
| `rust` | Langages | rustc et cargo, `~/.cargo/bin` dans le PATH (optionnel) | rustup |
| `php` | Langages | PHP, Composer, extensions mbstring/xml/curl/zip (optionnel) | installe PHP + Composer |
| `node` | Web | Node ≥ 20, npm, préfixe npm utilisateur | install / préfixe `~/.nos/npm-global` |
| `python` | Web | Python 3, pip, venv | installe `python3-pip python3-venv` |
| `docker` | DevOps | docker, compose, groupe docker, démon actif | install, `usermod`, `systemctl` |
| `path` | Environnement | dossiers N-OS dans le PATH | met à jour `~/.nos/env.sh` |
| `env_vars` | Environnement | `JAVA_HOME`, `ANDROID_HOME`, `FLUTTER_ROOT` valides | régénère `~/.nos/env.sh` |
| `nos_env` | Environnement | `~/.nos/env.sh` présent et chargé | crée et ajoute au `.bashrc` |
| `vscode` | IDE | VS Code présent | installe VS Code |
| `disk` | Système | ≥ 20 Go libres recommandés | aucune |
| `security` | Système | UFW actif, mises à jour automatiques | active UFW |
| `ai` | IA | au moins un assistant | aucune |
| `office` | Bureautique | LibreOffice, français, polices Office, CUPS (bloquant si un profil bureautique/education/administration est appliqué) | installe LibreOffice fr + CUPS |
| `education` | Profils | LaTeX, Jupyter, R, Octave, Xournal++, compte salle de TP (bloquant si le profil education est appliqué) | `nos profile apply education` |
| `administration` | Profils | ClamAV, Déjà Dup, Remmina, realmd, durcissement sudo/dconf (bloquant si le profil administration est appliqué) | `nos profile apply administration` |

## États

- ✔ **ok** : rien à faire.
- ! **warn** : fonctionne mais incomplet ; un conseil est affiché.
- ✘ **fail** : bloquant ; code de retour 1 (sauf `--no-fail`).

## Format JSON

```json
{
  "tool": "nos-doctor",
  "nos_version": "1.0.0-alpha.1",
  "system": "Naabiga OS 1.0.0-alpha.1 (Bobo)",
  "date": "2026-09-11T10:00:00Z",
  "summary": {"ok": 14, "warn": 2, "fail": 0, "total": 16},
  "checks": [
    {"id": "git", "label": "Git", "category": "Base", "status": "ok", "message": "git 2.43 (…)", "hint": "", "repaired": false}
  ]
}
```

## Écrire une vérification

Un fichier `apps/nos-doctor/lib/checks/NN-<id>.sh` avec `doctor_register`, `check_<id>` (appelle `doctor_result <ok|warn|fail> "message" "conseil"`) et, si possible, `repair_<id>`. Voir `apps/README.md`.

## Critère de réussite du projet

Sur une installation neuve de N-OS, `nos doctor` doit être **sans échec** (critère de la spécification maîtresse §13). C'est un test bloquant de la QA avant chaque release.
