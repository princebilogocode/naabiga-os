#!/usr/bin/env bash
# nos config : configuration de la CLI
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_config() {
  local action="${1:-list}"
  case "$action" in
    get)
      [ -n "${2:-}" ] || nos_die "Usage : nos config get <clé>"
      nos_config_get "$2"; printf '\n'
      ;;
    set)
      [ -n "${2:-}" ] && [ -n "${3:-}" ] || nos_die "Usage : nos config set <clé> <valeur>"
      nos_config_set "$2" "$3"
      nos_ok "$2 = $3"
      ;;
    list)
      if [ -f "$NOS_CONFIG_FILE" ] && [ -s "$NOS_CONFIG_FILE" ]; then
        cat "$NOS_CONFIG_FILE"
      else
        nos_info "Aucune configuration ($NOS_CONFIG_FILE)."
      fi
      ;;
    path) printf '%s\n' "$NOS_CONFIG_FILE" ;;
    *) nos_die "Usage : nos config <get|set|list|path>" ;;
  esac
}
