#!/usr/bin/env bash
# nos version
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_version() {
  case "${1:-}" in
    --short|-s) nos_version; printf '\n' ;;
    *)
      printf '%s %s\n' "$NOS_NAME" "$(nos_version)"
      printf 'Base     : %s\n' "$(nos_os_pretty)"
      printf 'Mode CLI : %s\n' "$NOS_MODE"
      ;;
  esac
}
