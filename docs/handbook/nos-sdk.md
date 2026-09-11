# N-OS SDK Manager (`nos sdk`)

Plusieurs versions de **Flutter**, **Java**, **Node.js** et **Android SDK** par utilisateur, sans sudo, et un seul fichier d'environnement.

```bash
nos sdk list                      # versions installées, version active
nos sdk install flutter stable    # ou beta, master, 3.24.5
nos sdk install java 17           # Eclipse Temurin via l'API Adoptium (17, 21…)
nos sdk install node lts          # ou latest, 22, 20.11.0
nos sdk install android latest    # cmdline-tools + platform-tools + build-tools 34 + API 34
nos sdk use java 21               # active une version
nos sdk remove node 20.11.0
nos sdk current
nos sdk env                       # affiche ~/.nos/env.sh
```

## Fonctionnement

```text
~/.nos/sdk/
├── flutter/{stable,3.24.5}/   current -> stable
├── java/{17,21}/              current -> 17
├── node/{22.3.0, lts -> 22.3.0}/  current -> 22.3.0
└── android/latest/            current -> latest
~/.nos/env.sh                  généré par nos sdk use (PATH, JAVA_HOME, ANDROID_HOME, FLUTTER_ROOT)
```

`~/.nos/env.sh` est chargé par `/etc/profile.d/nos.sh` (paquet `nos-cli`) et par le `.bashrc`. Après `nos sdk use`, rechargez le shell :

```bash
source ~/.nos/env.sh
```

## SDK système de l'ISO

L'image fournit Flutter stable et Node.js LTS dans `/opt/nos/sdk` (profil `/etc/profile.d/nos-sdk.sh`) et OpenJDK 17 par APT. Les SDK utilisateur (`nos sdk use`) passent devant dans le PATH.

## Sources

| SDK | Source | Vérification |
|---|---|---|
| Flutter | `git clone --depth 1 -b <tag|branche> github.com/flutter/flutter` | Git |
| Java | `api.adoptium.net` (Temurin, GA, HotSpot) | HTTPS ; SHA256 en Beta (nos-core Rust) |
| Node.js | `nodejs.org/dist` (index.json pour résoudre `lts`) | HTTPS ; SHASUMS256 en Beta |
| Android | `dl.google.com/android/repository/commandlinetools-linux-*` | licences acceptées via `sdkmanager --licenses` |

Variables : `NOS_SDK_DIR`, `NOS_ANDROID_CMDLINE_URL`, `NOS_ANDROID_PACKAGES`.
