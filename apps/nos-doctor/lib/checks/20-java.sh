#!/usr/bin/env bash
# Vérification : Java (JDK 17 LTS recommandé)
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register java "Java JDK" "Android & Flutter"

check_java() {
  if ! nos_has java; then
    doctor_result fail "java introuvable" "nos sdk install java 17"
    return
  fi
  local raw major
  raw="$(java -version 2>&1 | head -n 1 | tr -d '\r')"
  major="$(printf '%s' "$raw" | sed -E 's/.*"([0-9]+)(\.[0-9]+)*.*/\1/')"
  if ! nos_has javac; then
    doctor_result warn "$raw : javac absent (JRE seul)" "nos sdk install java 17"
    return
  fi
  if [ -z "${JAVA_HOME:-}" ]; then
    doctor_result warn "$raw : JAVA_HOME non défini" "nos sdk use java $major (définit JAVA_HOME dans ~/.nos/env.sh)"
    return
  fi
  case "$major" in
    17|21) doctor_result ok "$raw (JAVA_HOME=$JAVA_HOME)" ;;
    *) doctor_result warn "$raw : Android Studio et Gradle recommandent Java 17 LTS" "nos sdk install java 17" ;;
  esac
}

repair_java() {
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  sdk_main install java 17 && sdk_main use java 17
}
