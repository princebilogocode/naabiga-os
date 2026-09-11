#!/usr/bin/env bash
# Vérification : adb / fastboot
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register adb "adb / fastboot" "Android & Flutter"

check_adb() {
  if ! nos_has adb; then
    doctor_result fail "adb introuvable" "nos install android-sdk (platform-tools) ou sudo apt install adb"
    return
  fi
  local v
  v="$(adb version 2>/dev/null | head -n 1 | tr -d '\r')"
  if ! nos_has fastboot; then
    doctor_result warn "$v : fastboot absent" "sudo apt install fastboot"
    return
  fi
  if nos_is_linux && [ ! -f /etc/udev/rules.d/51-android.rules ] && ! dpkg -s android-sdk-platform-tools-common >/dev/null 2>&1; then
    doctor_result warn "$v : règles udev Android absentes (appareils USB non détectés)" "sudo apt install android-sdk-platform-tools-common"
    return
  fi
  doctor_result ok "$v"
}

repair_adb() {
  nos_apt_install adb fastboot android-sdk-platform-tools-common
}
