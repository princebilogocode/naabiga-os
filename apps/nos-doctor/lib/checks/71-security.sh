#!/usr/bin/env bash
# Vérification : sécurité de base (pare-feu, mises à jour automatiques)
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register security "Sécurité (UFW, mises à jour)" "Système"

check_security() {
  if ! nos_is_linux; then
    doctor_result warn "vérification réservée à Linux"
    return
  fi
  local problems=()
  if nos_has ufw; then
    if ! ufw status 2>/dev/null | grep -qi 'Status: active'; then
      [ -f /etc/ufw/ufw.conf ] && grep -q '^ENABLED=yes' /etc/ufw/ufw.conf 2>/dev/null || problems+=("UFW inactif")
    fi
  else
    problems+=("UFW absent")
  fi
  if ! dpkg -s unattended-upgrades >/dev/null 2>&1; then
    problems+=("unattended-upgrades absent")
  fi
  if [ "${#problems[@]}" -gt 0 ]; then
    doctor_result warn "${problems[*]}" "sudo bash $NOS_SCRIPTS/first-boot/40-firewall.sh"
    return
  fi
  doctor_result ok "pare-feu actif, mises à jour de sécurité automatiques"
}

repair_security() {
  nos_is_linux || return 1
  nos_apt_install ufw unattended-upgrades
  nos_sudo ufw --force enable
}
