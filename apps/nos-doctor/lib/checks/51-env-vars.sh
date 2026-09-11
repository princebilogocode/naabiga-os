#!/usr/bin/env bash
# Vérification : variables d'environnement de développement
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register env_vars "Variables d'environnement" "Environnement"

check_env_vars() {
  local problems=()
  if [ -n "${JAVA_HOME:-}" ] && [ ! -x "$JAVA_HOME/bin/java" ]; then
    problems+=("JAVA_HOME invalide ($JAVA_HOME)")
  fi
  if [ -n "${ANDROID_HOME:-}" ] && [ ! -d "$ANDROID_HOME" ]; then
    problems+=("ANDROID_HOME invalide ($ANDROID_HOME)")
  fi
  if [ -n "${ANDROID_SDK_ROOT:-}" ] && [ -n "${ANDROID_HOME:-}" ] && [ "$ANDROID_SDK_ROOT" != "$ANDROID_HOME" ]; then
    problems+=("ANDROID_SDK_ROOT ≠ ANDROID_HOME")
  fi
  if [ -n "${FLUTTER_ROOT:-}" ] && [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
    problems+=("FLUTTER_ROOT invalide ($FLUTTER_ROOT)")
  fi
  if [ "${#problems[@]}" -gt 0 ]; then
    doctor_result warn "${problems[*]}" "Corrigez ~/.nos/env.sh ou lancez nos sdk use <sdk> <version>"
    return
  fi
  local defined=()
  [ -n "${JAVA_HOME:-}" ] && defined+=("JAVA_HOME")
  [ -n "${ANDROID_HOME:-}" ] && defined+=("ANDROID_HOME")
  [ -n "${FLUTTER_ROOT:-}" ] && defined+=("FLUTTER_ROOT")
  if [ "${#defined[@]}" -eq 0 ]; then
    doctor_result warn "aucune variable SDK définie (JAVA_HOME, ANDROID_HOME, FLUTTER_ROOT)" "nos sdk use java 17 / nos sdk use android / nos sdk use flutter"
    return
  fi
  doctor_result ok "définies : ${defined[*]}"
}

repair_env_vars() {
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  sdk_write_env
}
