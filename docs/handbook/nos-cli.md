# N-OS CLI (`nos`)

Point d'entrée unique de l'écosystème. Une commande, des sous-commandes.

```text
nos <commande> [options]
```

| Commande | Rôle |
|---|---|
| `doctor` | Diagnostic et réparation ([détails](nos-doctor.md)) |
| `install <outil>…` | Installer depuis le [catalogue](tools.md) |
| `remove <outil>…` | Désinstaller |
| `update [--system] [--sdk] [--ai]` | Mettre à jour APT/Flatpak, SDK, assistants IA |
| `repair` | Alias de `doctor --repair` |
| `sdk` | Versions de Flutter, Java, Node.js, Android SDK ([détails](nos-sdk.md)) |
| `ai` | Assistants IA ([détails](nos-ai.md)) |
| `profile list|show|apply` | Profils d'usage : dev, bureautique, education, administration ([détails](profiles.md)) |
| `info` | Système, outils et assistants installés |
| `config get|set|list` | Configuration (`~/.config/nos/config`) |
| `version` | Version de N-OS |
| `help` | Aide |

## Variables d'environnement

| Variable | Effet |
|---|---|
| `NOS_DRY_RUN=1` | Affiche les commandes sans les exécuter (utilisé par les tests) |
| `NO_COLOR=1` | Désactive les couleurs |
| `NOS_SDK_DIR` | Dossier des SDK (défaut `~/.nos/sdk`) |
| `NOS_CATALOG` | Chemin du catalogue TSV |
| `NOS_ANDROID_CMDLINE_URL` | URL des cmdline-tools Android |

## Codes de retour

`0` succès · `1` erreur ou échec Doctor · `2` commande ou option inconnue.

## Complétion

Installée avec le paquet `nos-cli` (`/usr/share/bash-completion/completions/nos`).

## Fichiers

| Chemin | Contenu |
|---|---|
| `~/.nos/env.sh` | Variables des SDK actifs (chargé par `/etc/profile.d/nos.sh`) |
| `~/.nos/sdk/` | SDK par version |
| `~/.config/nos/config` | Configuration |
| `/usr/lib/nos/` | Bibliothèques de la CLI |
| `/usr/share/nos/catalog.tsv` | Catalogue |
| `/etc/nos-release` | Version et identité de N-OS |

## Développement

Voir `apps/README.md` pour l'architecture interne, l'ajout d'une commande, d'une vérification Doctor ou d'un outil au catalogue.
