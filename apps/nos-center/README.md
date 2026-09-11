# N-OS Center

Centre logiciel graphique de Naabiga OS, écrit en **Flutter Desktop (Linux)**, conformément au Software Architecture Document (§5, technologie recommandée : Flutter Desktop).

N-OS Center n'installe rien lui-même : c'est une interface au-dessus de la CLI `nos`, ce qui garantit un comportement identique en graphique et en terminal.

| Page | Commande sous-jacente |
|---|---|
| Doctor | `nos doctor --json`, `nos doctor --repair --json` |
| Outils | `catalog.tsv` + `nos install <id>` |
| SDK | `nos sdk list`, `nos sdk install`, `nos sdk use` |
| IA | `nos ai install`, `nos ai remove` |
| Profils | `nos profile apply <dev|bureautique|education|administration>` |

## Développement

```bash
cd apps/nos-center
mkdir -p assets && cp ../../branding/logo/naabiga-os-logo.png assets/logo.png
flutter create --platforms=linux .      # génère le dossier linux/ (non versionné en Alpha)
flutter pub get
NOS_BIN=$PWD/../nos-cli/bin/nos NOS_CATALOG=$PWD/../nos-cli/share/catalog.tsv flutter run -d linux
```

Tests et analyse :

```bash
flutter analyze
flutter test
```

## Construction et packaging

```bash
flutter build linux --release
# → build/linux/x64/release/bundle/  (packagé en .deb « nos-center » en phase Beta)
```

## État

- **Alpha** : squelette fonctionnel (5 pages, thème NAABIGA, flux de sortie des commandes).
- **Beta** : paquet `.deb`, notifications de mises à jour, extensions VS Code, gestion des dépôts N-OS.
