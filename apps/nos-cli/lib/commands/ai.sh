#!/usr/bin/env bash
# nos ai : délègue à N-OS AI Hub
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_ai() {
  # shellcheck source=../../../nos-ai/lib/ai.sh
  source "$NOS_AI_LIB/ai.sh"
  ai_main "$@"
}
