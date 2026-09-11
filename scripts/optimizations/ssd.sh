#!/usr/bin/env bash
# Optimisation SSD/NVMe : ordonnanceur d'E/S adapté, noatime sur la racine
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# Ordonnanceur : none pour NVMe, mq-deadline pour SSD SATA, bfq pour disques rotatifs
$SUDO tee /etc/udev/rules.d/60-naabiga-scheduler.rules >/dev/null <<'EOF'
# Naabiga OS — ordonnanceurs d'E/S
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
$SUDO udevadm control --reload-rules 2>/dev/null || true

# noatime sur / si absent (réduit les écritures)
if [ -f /etc/fstab ] && grep -qE '^[^#].*[[:space:]]/[[:space:]]+(ext4|btrfs|xfs)[[:space:]]+' /etc/fstab && ! grep -qE '^[^#].*[[:space:]]/[[:space:]].*noatime' /etc/fstab; then
  $SUDO cp /etc/fstab /etc/fstab.nos-backup
  $SUDO sed -i -E 's#^([^#]\S*[[:space:]]+/[[:space:]]+(ext4|btrfs|xfs)[[:space:]]+)(\S+)#\1\3,noatime#' /etc/fstab
  echo "noatime ajouté à / (sauvegarde : /etc/fstab.nos-backup)."
fi
echo "Optimisation SSD appliquée."
