# Décisions d'architecture (ADR)

Format court : contexte, décision, conséquences. Une décision se change par une nouvelle ADR qui remplace l'ancienne.

## ADR-001 — Socle Linux LTS

**Contexte.** Stabilité, support matériel, dépôts riches, familiarité des étudiants et des entreprises.
**Décision.** N-OS s'appuie sur un socle Linux LTS de génération « noble » (support 5 ans) ; l'identifiant technique du socle reste dans `/etc/os-release` pour la compatibilité des dépôts et installateurs tiers, tandis que tout ce qui est visible (`PRETTY_NAME`, `NAME`, `lsb_release`, `/etc/nos-release`, écran d'installation, message d'accueil) porte exclusivement l'identité Naabiga OS.
**Conséquences.** Cycle de publication LTS (nouvelle base tous les 2 ans, support 5 ans) ; pas de modification profonde du socle.

## ADR-002 — Bureau Cinnamon

**Contexte.** Bureau familier (proche de Windows), léger, stable, bien intégré aux outils GTK.
**Décision.** Cinnamon avec LightDM + Slick Greeter. Thème Alpha : Yaru-red-dark + Papirus-Dark ; thème N-OS dédié en Beta.
**Conséquences.** Le paquet `cinnamon-desktop-environment` vient d'`universe` ; N-OS assure ses propres tests.

## ADR-003 — Installateur Calamares

**Contexte.** Installateur graphique multi-distributions, configurable en YAML, supporte LUKS.
**Décision.** Calamares, français par défaut, chiffrement proposé.
**Conséquences.** Configuration versionnée dans `installer/calamares/`.

## ADR-004 — APT + Flatpak, pas de Snap par défaut

**Contexte.** Snap est lent au démarrage, propriétaire côté serveur, et rend les navigateurs plus lourds.
**Décision.** Paquets `.deb` (dépôts du socle + dépôt N-OS) et Flatpak (Flathub). `snapd` est épinglé à une priorité négative ; l'utilisateur peut le réactiver.
**Conséquences.** Firefox est fourni en `.deb`/Flatpak ; certains logiciels Snap-only passent par `nos install`.

## ADR-005 — CLI en Bash pour l'Alpha, Rust ensuite

**Contexte.** Le SAD recommande Rust + Bash. Les étudiants doivent pouvoir contribuer immédiatement ; Bash est universel sur la base.
**Décision.** `nos`, Doctor, SDK Manager et AI Hub sont en Bash (shellcheck obligatoire, tests bats). En Beta, un cœur `nos-core` en Rust prend en charge téléchargements, vérification d'intégrité et versions ; la CLI Bash reste le frontal.
**Conséquences.** Une seule logique d'installation, partagée par la CLI et N-OS Center.

## ADR-006 — N-OS Center en Flutter Desktop

**Contexte.** Compétence Flutter forte chez ICONEDOR et dans le cursus U-AUBEN ; cohérence avec l'écosystème NAABIGA.
**Décision.** Flutter Desktop (Linux). N-OS Center ne fait qu'appeler `nos` (JSON, flux de sortie).
**Conséquences.** Comportement identique graphique/terminal ; pas de logique d'installation dupliquée.

## ADR-007 — SDK dans l'espace utilisateur

**Contexte.** Plusieurs versions de Flutter/Java/Node par développeur ; pas de sudo pour changer de version.
**Décision.** `~/.nos/sdk/<sdk>/<version>` + lien `current` + `~/.nos/env.sh` (chargé par `/etc/profile.d/nos.sh`). L'image ISO fournit aussi des SDK système dans `/opt/nos/sdk`.
**Conséquences.** `nos sdk use` ne touche jamais au système ; `nos doctor` vérifie la cohérence PATH/variables.

## ADR-008 — Documentation MkDocs Material, en français

**Décision.** Markdown dans `docs/`, publié sur GitHub Pages par la CI. Le français est la langue par défaut ; l'anglais viendra par traduction communautaire.

## ADR-009 — GitFlow, Conventional Commits, SemVer

**Décision.** `main` (releases taguées), `develop`, `feature/*`, `release/*`, `hotfix/*`. Version dans `VERSION` (SemVer ; `1.0.0-alpha.1` → `1.0.0~alpha.1` pour Debian).

## ADR-010 — Sécurité activée par défaut

**Décision.** UFW activé, AppArmor, `unattended-upgrades`, Secure Boot via chargeur signé, LUKS proposé, ISO avec `SHA256SUMS` signé GPG.
