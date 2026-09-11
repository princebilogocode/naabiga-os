#!/usr/bin/env bash
# nos doctor : délègue à N-OS Doctor
# SPDX-License-Identifier: GPL-3.0-or-later

cmd_doctor() {
  # shellcheck source=../../../nos-doctor/lib/doctor.sh
  source "$NOS_DOCTOR_LIB/doctor.sh"
  doctor_main "$@"
}
