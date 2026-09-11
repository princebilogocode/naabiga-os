#!/usr/bin/env bash
# nos repair — alias de nos doctor --repair
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_repair() {
  # shellcheck source=../../../nos-doctor/lib/doctor.sh
  source "$NOS_DOCTOR_LIB/doctor.sh"
  doctor_main --repair "$@"
}
