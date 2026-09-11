#!/usr/bin/env bash
# Premier démarrage : groupes utiles aux développeurs (docker, kvm, plugdev, dialout)
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

for g in docker kvm plugdev dialout; do
  getent group "$g" >/dev/null || groupadd -f "$g"
done

# Tous les comptes humains (UID >= 1000)
while IFS=: read -r name _ uid _ _ home shell; do
  [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ] && [ -d "$home" ] && [[ "$shell" != */nologin && "$shell" != */false ]] || continue
  for g in docker kvm plugdev dialout; do
    usermod -aG "$g" "$name" 2>/dev/null || true
  done
  # Profil N-OS
  install -d -o "$name" -g "$name" "$home/.nos"
  [ -f "$home/.nos/env.sh" ] || printf '# Généré par N-OS\nexport PATH="$HOME/.local/bin:$PATH"\n' > "$home/.nos/env.sh"
  chown "$name:$name" "$home/.nos/env.sh"
done < /etc/passwd
