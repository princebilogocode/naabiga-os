# Sécurité

Politique de signalement : `SECURITY.md` (security@iconedor.com, pas d'issue publique).

## Mesures par défaut

| Mesure | Mise en œuvre |
|---|---|
| Secure Boot | chargeur et GRUB signés (`shim-signed`, `grub-efi-amd64-signed`) |
| Pare-feu | UFW activé au premier démarrage : entrant refusé, sortant autorisé, ports de dev (3000, 5173, 8000, 8080) ouverts au réseau local seulement |
| AppArmor | actif, profils du socle |
| Mises à jour | `unattended-upgrades` pour les correctifs de sécurité ; `nos update` pour le reste |
| Chiffrement | LUKS2 proposé dans Calamares ; saisie du mot de passe dans Plymouth |
| Intégrité | ISO avec `.sha256` (+ signature GPG en release) ; paquets N-OS signés (dépôts RC) |
| Comptes | pas de root ; sudo via mot de passe utilisateur ; auto-login désactivé ; verrouillage d'écran après 5 min |
| Noyau | `kptr_restrict`, `rp_filter` (`/etc/sysctl.d/99-naabiga-sysctl.conf`) |

## Aucun secret dans le dépôt

Le dépôt ne doit contenir **aucune clé API, jeton, mot de passe, clé privée ni fichier de credentials** (Firebase, comptes de service, keystores, etc.).

- `.gitignore` exclut les fichiers sensibles (`.env*`, `*.pem`, `*.key`, `*.jks`, `google-services.json`, `*firebase-adminsdk*.json`, `secrets/`, etc.).
- `scripts/check-secrets.sh` détecte les motifs de secrets (AWS, GitHub, Google, Anthropic/OpenAI, Slack, JWT, clés privées, `password=`) et les noms de fichiers interdits. Il tourne dans `make lint`, dans le hook pre-commit (`make hooks`) et dans la CI (job "Aucun secret versionné", complété par Gitleaks sur tout l'historique).
- Les secrets nécessaires (clé GPG de signature, jetons de publication) sont fournis via les **secrets GitHub Actions** ou des variables d'environnement, jamais dans le code.
- Un secret exposé par erreur doit être **révoqué immédiatement**, puis l'historique nettoyé (`git filter-repo`) et signalé à security@iconedor.com.

## Développeurs et sécurité

- `docker` sans sudo : l'utilisateur est dans le groupe `docker` (équivalent root local). C'est un choix assumé pour l'expérience développeur ; les postes partagés peuvent retirer le groupe.
- Les assistants IA (`nos ai`) stockent leurs jetons dans le dossier utilisateur ; aucune clé n'est demandée ou stockée par N-OS.
- Les scripts d'installation tiers (`scripts/dev-tools/`) utilisent uniquement les dépôts et URL officiels des éditeurs, en HTTPS, avec clés GPG pour APT.

## À venir

- Vérification SHA256 des archives SDK dans `nos-core` (Rust).
- Signature des paquets et du dépôt `repo.naabiga.org`.
- Durcissement optionnel « poste partagé » (`nos config set profile shared`) : pas de groupe docker, auto-lock 2 min, USB restreint.
