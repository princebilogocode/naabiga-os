# Catalogue d'outils (`nos install`)

Source : `apps/nos-cli/share/catalog.tsv` (installé dans `/usr/share/nos/catalog.tsv`). `nos install --list` affiche la liste à jour avec l'état d'installation.

| Catégorie | Outils |
|---|---|
| Base | git, curl, wget, openssh, build-essential, clang, cmake, ffmpeg |
| IDE | vscode, android-studio |
| Langages | java, kotlin, flutter, android-sdk, node, pnpm, yarn, python, php, composer, go, rust |
| DevOps | docker, nginx, apache |
| Bases de données | postgresql-client, sqlite, redis-cli |
| Tests | playwright |
| Navigateurs | chrome (propriétaire, via dépôt Google), firefox (Flatpak) |
| IA | claude, gemini, ollama, aider, opencode, continue, copilot |

## Méthodes d'installation

| Méthode | Mécanisme |
|---|---|
| `apt` | `apt-get install` (dépôts du socle) |
| `flatpak` | Flathub |
| `npm` / `pipx` | paquet global |
| `script` | script dans `scripts/dev-tools/` (dépôts tiers : VS Code, Docker, Chrome ; archives : Android Studio, Kotlin ; rustup ; Playwright) |
| `sdk` | délégué à `nos sdk` |
| `ai` | délégué à `nos ai` |

## Ce que contient l'ISO

Préinstallés : Git, VS Code, OpenJDK 17, Maven, Gradle, adb/fastboot, Flutter stable, Node.js LTS, Python 3, PHP 8, Composer, Go, Docker + Compose, Nginx, SQLite, clients PostgreSQL et Redis, FFmpeg, GCC/Clang/CMake, Playwright (npm), Firefox, Claude Code, Gemini CLI, OpenCode.

À installer après coup (taille ou licence) : Android Studio, Google Chrome, Rust, Kotlin, Ollama, Aider.

## Désinstaller

`nos remove <outil>` pour apt, flatpak, npm, pipx, sdk, ai. Les outils `script` se désinstallent manuellement :

| Outil | Désinstallation |
|---|---|
| vscode | `sudo apt remove code` |
| android-studio | `sudo rm -rf /opt/android-studio /usr/local/bin/android-studio /usr/share/applications/android-studio.desktop` |
| docker | `sudo apt remove docker-ce docker-ce-cli containerd.io` |
| rust | `rustup self uninstall` |
| chrome | `sudo apt remove google-chrome-stable` |
| kotlin | `sudo rm -rf /opt/kotlinc /usr/local/bin/kotlin*` |
| playwright | `npm uninstall -g playwright` |
