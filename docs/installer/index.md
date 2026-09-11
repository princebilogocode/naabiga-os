# Installateur

N-OS utilise **Calamares** ([ADR-003](../architecture/decisions.md)). Configuration : `installer/calamares/` (voir son `README.md`).

## Parcours utilisateur

1. **Bienvenue** : langue (français par défaut), prérequis (25 Go, 2 Go RAM, secteur, Internet recommandé).
2. **Localisation** : fuseau Africa/Ouagadougou par défaut (géolocalisation si Internet).
3. **Clavier** : français par défaut.
4. **Partitions** : effacer le disque (ext4), option **chiffrement LUKS2**, ou manuel ; swap : aucun par défaut (ZRAM), fichier ou partition possibles.
5. **Utilisateurs** : nom, machine, mot de passe (réutilisé pour sudo ; pas de compte root), groupes développeur.
6. **Résumé**, puis installation avec diaporama N-OS (5 diapositives).
7. **Terminé** : redémarrage proposé.

## Après installation

- Les paquets live (`casper`, `live-*`, `calamares`) sont retirés.
- `shellprocess@nos-cli` réactive `nos-first-boot`, `fstrim.timer`, `zramswap` et régénère l'initramfs (Plymouth).
- Au premier démarrage : optimisations, pare-feu, Flathub, groupes.

## Tests à effectuer avant release

- BIOS et UEFI (Secure Boot activé).
- Disque vide, dual-boot Windows, LUKS.
- NVIDIA / AMD / Intel (session live et installée).
- Clavier et langue conservés après installation.
- `nos doctor` sans échec après le premier démarrage.

Checklist complète : [QA](../qa/index.md).
