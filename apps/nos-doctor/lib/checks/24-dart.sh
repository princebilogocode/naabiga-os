#!/usr/bin/env bash
# Vérification : Dart
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register dart "Dart SDK" "Android & Flutter"

check_dart() {
  if ! nos_has dart; then
    if nos_has flutter; then
      doctor_result warn "dart absent du PATH (fourni par Flutter)" "nos sdk use flutter (ajoute flutter/bin/cache/dart-sdk/bin au PATH)"
    else
      doctor_result fail "dart introuvable" "nos sdk install flutter stable"
    fi
    return
  fi
  local v
  v="$(dart --version 2>&1 | head -n 1 | tr -d '\r' | awk '{print "Dart "$4}')"
  doctor_result ok "$v"
}

repair_dart() {
  repair_flutter
}
