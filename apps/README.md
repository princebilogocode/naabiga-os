# apps/ — applications officielles N-OS

| Application | Dossier | Langage | Commande | État |
|---|---|---|---|---|
| N-OS CLI | `nos-cli/` | Bash | `nos` | Alpha fonctionnel |
| N-OS Doctor | `nos-doctor/` | Bash | `nos doctor` | Alpha fonctionnel (22 vérifications, réparation, JSON, HTML) |
| N-OS SDK Manager | `nos-sdk/` | Bash | `nos sdk` | Alpha fonctionnel (Flutter, Java, Node.js, Android SDK) |
| N-OS AI Hub | `nos-ai/` | Bash | `nos ai` | Alpha fonctionnel (7 assistants) |
| Profils d'usage | `nos-cli/share/profiles/` + `scripts/profiles/` | Bash | `nos profile` | Alpha fonctionnel (dev, bureautique, education, administration) |
| N-OS Center | `nos-center/` | Flutter Desktop | `nos-center` | Squelette (Alpha) |

## Architecture de la CLI

```text
nos (apps/nos-cli/bin/nos)
 ├── lib/core.sh                 journalisation, couleurs, dry-run, sudo, config, JSON, catalogue
 ├── lib/commands/<cmd>.sh       une fonction cmd_<cmd> par sous-commande
 ├── share/catalog.tsv           catalogue nos install (id, catégorie, description, méthode, spec, exécutable)
 ├── share/profiles/*.profile    profils d'usage (outils + paquets + optimisations)
 ├── → apps/nos-doctor/lib       doctor_main + checks/NN-<id>.sh (check_<id>, repair_<id>)
 ├── → apps/nos-sdk/lib          sdk_main (install/use/remove, ~/.nos/sdk, ~/.nos/env.sh)
 └── → apps/nos-ai/lib           ai_main (npm, pipx, script, extension VS Code)
```

Deux modes de résolution des chemins :

- **dépôt** : `bash apps/nos-cli/bin/nos …` (les bibliothèques sont cherchées dans `apps/*/lib`) ;
- **installé** : `/usr/bin/nos` avec `/usr/lib/nos/{lib,doctor,sdk,ai,scripts}` et `/usr/share/nos/catalog.tsv` (via `make install-cli` ou le paquet `nos-cli`).

`NOS_DRY_RUN=1` affiche les commandes sans les exécuter : c'est ce qu'utilisent les tests.

## Ajouter une vérification Doctor

1. Créez `apps/nos-doctor/lib/checks/NN-<id>.sh` :

```bash
#!/usr/bin/env bash
doctor_register go "Go" "Langages"
check_go() {
  nos_has go || { doctor_result fail "go introuvable" "nos install go"; return; }
  doctor_result ok "$(go version)"
}
repair_go() { nos_apt_install golang-go; }
```

2. Ajoutez un test dans `tests/unit/doctor.bats`.
3. `make lint test`.

## Ajouter un outil au catalogue

Une ligne dans `apps/nos-cli/share/catalog.tsv` (colonnes séparées par des **tabulations**) : `id`, `catégorie`, `description`, `méthode` (`apt`, `flatpak`, `npm`, `pipx`, `script`, `sdk`, `ai`), `spec`, `exécutable`. Pour `script`, placez le script dans `scripts/dev-tools/`.

## Roadmap technique

- Beta : portage des parties critiques (téléchargements, vérification SHA256, gestion des versions) en **Rust** (`nos-core`), la CLI Bash devenant un frontal.
- Beta : `nos-center` packagé en `.deb`, notifications, intégration N-OS Update Server.
