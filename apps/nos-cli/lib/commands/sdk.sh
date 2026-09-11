#!/usr/bin/env bash
# nos sdk : délègue à N-OS SDK Manager
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_sdk() {
  # shellcheck source=../../../nos-sdk/lib/sdk.sh
  source "$NOS_SDK_LIB/sdk.sh"
  sdk_main "$@"
}
