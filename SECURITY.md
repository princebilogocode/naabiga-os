# Politique de sécurité

## Versions supportées

| Version | Support |
|---|---|
| 1.0.x LTS (à venir) | Oui, support long terme de 5 ans |
| Alpha / Beta | Correctifs au fil de l'eau, sans garantie |

## Signaler une vulnérabilité

**Ne créez pas d'issue publique.**

Envoyez un courriel à **security@iconedor.com** avec :

- une description du problème et son impact ;
- les étapes de reproduction ;
- la version de N-OS concernée (`nos version`).

Nous accusons réception sous 72 heures et publions un correctif coordonné.

## Mesures de sécurité par défaut de N-OS

- Secure Boot compatible (chargeur signé).
- Pare-feu UFW activé au premier démarrage (`scripts/first-boot/40-firewall.sh`).
- AppArmor actif.
- Mises à jour de sécurité automatiques (`unattended-upgrades`).
- Paquets N-OS et dépôts signés GPG, ISO accompagnée d'un `SHA256SUMS` signé.
- Chiffrement du disque (LUKS) proposé dans l'installateur Calamares.
