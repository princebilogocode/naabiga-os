#!/usr/bin/env bash
# Vérification : Docker
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register docker "Docker" "DevOps"

check_docker() {
  if ! nos_has docker; then
    doctor_result fail "docker introuvable" "nos install docker"
    return
  fi
  local v
  v="$(docker --version 2>/dev/null | tr -d '\r' | sed -E 's/,.*//')"
  if ! docker compose version >/dev/null 2>&1; then
    doctor_result warn "$v — plugin docker compose absent" "sudo apt install docker-compose-plugin"
    return
  fi
  if nos_is_linux && nos_has id && ! id -nG 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
    doctor_result warn "$v — l'utilisateur ${USER:-} n'est pas dans le groupe docker" "sudo usermod -aG docker \$USER puis reconnectez-vous"
    return
  fi
  if ! docker info >/dev/null 2>&1; then
    doctor_result warn "$v — le démon Docker ne répond pas" "sudo systemctl enable --now docker"
    return
  fi
  doctor_result ok "$v, compose $(docker compose version --short 2>/dev/null | tr -d '\r')"
}

repair_docker() {
  if ! nos_has docker; then
    nos_run bash "$NOS_SCRIPTS/dev-tools/install-docker.sh" || return 1
  fi
  if nos_is_linux; then
    if ! id -nG 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
      nos_sudo usermod -aG docker "${USER:-$(id -un)}"
    fi
    if nos_has systemctl; then
      nos_sudo systemctl enable --now docker
    fi
  fi
}
