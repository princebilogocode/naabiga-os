#!/usr/bin/env bash
# Vérification : Flutter
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register flutter "Flutter SDK" "Android & Flutter"

check_flutter() {
  if ! nos_has flutter; then
    doctor_result fail "flutter introuvable" "nos sdk install flutter stable"
    return
  fi
  local v
  v="$(flutter --version --suppress-analytics 2>/dev/null | head -n 1 | tr -d '\r' | awk '{print $1" "$2" ("$5")"}')"
  [ -n "$v" ] || v="flutter (version non lue)"
  local flutter_root
  flutter_root="$(cd "$(dirname "$(command -v flutter)")/.." 2>/dev/null && pwd)"
  if [ -n "$flutter_root" ] && [ -d "$flutter_root/.git" ] && [ ! -w "$flutter_root" ]; then
    doctor_result warn "$v — dossier Flutter non inscriptible ($flutter_root)" "sudo chown -R \$USER $flutter_root"
    return
  fi
  if [ ! -f "$flutter_root/bin/cache/dart-sdk/bin/dart" ] 2>/dev/null; then
    doctor_result warn "$v — cache Dart absent (premier lancement nécessaire)" "flutter precache"
    return
  fi
  doctor_result ok "$v"
}

repair_flutter() {
  if nos_has flutter; then
    nos_run flutter precache
    return 0
  fi
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  sdk_main install flutter stable && sdk_main use flutter stable
}
