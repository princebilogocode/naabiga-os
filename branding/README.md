# branding/ — identité visuelle de Naabiga OS

**Naabiga OS est le premier système d'exploitation conçu par des Burkinabè, pour les Burkinabè et pour l'Afrique.** Une fierté nationale portée par ICONEDOR et les étudiants de l'Université Aube Nouvelle de Bobo-Dioulasso.

Naabiga OS applique la [charte graphique NAABIGA](charte-graphique-naabiga.md). Couleurs produit de l'OS : **Rouge + Or**.

| Fichier | Usage |
|---|---|
| `logo/naabiga-os-logo.png` | Logo officiel (source PNG). Installé dans `/usr/share/nos/branding/logo.png`, icône `naabiga-os` |
| `palette/naabiga.json` | Palette, typographie et slogans lisibles par les scripts (`build/gen-assets.sh`, N-OS Center, rapports Doctor) |
| `wallpapers/naabiga-default.svg` | Fond d'écran par défaut (4K, vectoriel) |
| `wallpapers/naabiga-login.svg` | Fond de l'écran de connexion |
| `charte-graphique-naabiga.md` | Charte de l'écosystème (copie de référence) |

## Palette

| Couleur | Hex | Rôle dans N-OS |
|---|---|---|
| Rouge | `#D62828` | Couleur dominante : accents, actions, échecs Doctor |
| Or | `#D4AF37` | Prestige : titres, sélection GRUB, avertissements Doctor |
| Vert | `#198754` | Succès, validations Doctor |
| Noir | `#111111` | Fonds sombres (Plymouth, GRUB, login, terminal) |
| Blanc | `#FFFFFF` | Fonds clairs, texte sur sombre |

## Typographie

Titres : Poppins Bold (repli Inter Bold). Texte : Inter. Code : JetBrains Mono. Les polices Inter et JetBrains Mono sont fournies par les paquets `fonts-inter` et `fonts-jetbrains-mono`, préinstallés.

## Règles

- Le logo fonctionne en couleur, en noir, en blanc, sur fond clair et sombre ; pas de dégradé complexe.
- Coins arrondis 12 à 16 px, beaucoup d'espace, peu de texte : **moins, mais mieux**.
- Les icônes suivent un style minimaliste, épaisseur uniforme (Papirus en Alpha ; pack N-OS en Beta).

## Propriété

Le nom « Naabiga », le logo et la charte sont la propriété d'ICONEDOR. Le code du dépôt est sous GPL-3.0, mais toute redistribution modifiée de l'OS doit utiliser un autre nom et un autre logo (voir `docs/handbook/trademark.md`).

## Contribuer un fond d'écran

Format SVG (préféré) ou PNG 3840×2160, palette NAABIGA, sans texte autre que « Naabiga OS » et la devise. Proposez-le via une Pull Request dans `wallpapers/`.
