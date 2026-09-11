#!/usr/bin/env bash
# Vérification : Android SDK
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register android_sdk "Android SDK" "Android & Flutter"

doctor_android_home() {
  local candidate
  for candidate in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$NOS_SDK_DIR/android/current" "$HOME/Android/Sdk" "/opt/android-sdk"; do
    [ -n "$candidate" ] && [ -d "$candidate" ] && { printf '%s' "$candidate"; return 0; }
  done
  return 1
}

check_android_sdk() {
  local home
  if ! home="$(doctor_android_home)"; then
    doctor_result fail "Android SDK introuvable" "nos sdk install android"
    return
  fi
  local missing=()
  [ -d "$home/platform-tools" ] || missing+=("platform-tools")
  [ -d "$home/build-tools" ] || missing+=("build-tools")
  [ -d "$home/platforms" ] || missing+=("platforms")
  [ -d "$home/cmdline-tools" ] || missing+=("cmdline-tools")
  if [ "${#missing[@]}" -gt 0 ]; then
    doctor_result warn "SDK dans $home — composants manquants : ${missing[*]}" "sdkmanager \"platform-tools\" \"build-tools;34.0.0\" \"platforms;android-34\""
    return
  fi
  if [ -z "${ANDROID_HOME:-}" ]; then
    doctor_result warn "SDK dans $home — ANDROID_HOME non défini" "nos sdk use android"
    return
  fi
  if [ ! -f "$home/licenses/android-sdk-license" ]; then
    doctor_result warn "SDK dans $home — licences non acceptées" "yes | sdkmanager --licenses"
    return
  fi
  doctor_result ok "ANDROID_HOME=$home"
}

repair_android_sdk() {
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  if ! doctor_android_home >/dev/null; then
    sdk_main install android latest || return 1
  fi
  sdk_main use android
}
