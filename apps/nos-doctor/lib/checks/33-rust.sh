#!/usr/bin/env bash
# Vérification : Rust (rustup, cargo)
# SPDX-License-Identifier: GPL-3.0-or-later

doctor_register rust "Rust" "Langages"

check_rust() {
  if ! nos_has rustc; then
    if [ -x "$HOME/.cargo/bin/rustc" ]; then
      doctor_result warn "Rust installé mais ~/.cargo/bin absent du PATH" "source ~/.nos/env.sh (nos doctor --repair)"
    else
      doctor_result warn "rustc introuvable (optionnel)" "nos install rust"
    fi
    return
  fi
  local v
  v="$(rustc --version 2>/dev/null | tr -d '\r')"
  nos_has cargo || { doctor_result warn "$v — cargo absent" "nos install rust"; return; }
  doctor_result ok "$v, $(cargo --version 2>/dev/null | tr -d '\r')"
}

repair_rust() {
  if [ -x "$HOME/.cargo/bin/rustc" ]; then
    nos_ensure_line 'export PATH="$HOME/.cargo/bin:$PATH"' "$NOS_ENV_FILE"
    return 0
  fi
  nos_run bash "$NOS_SCRIPTS/dev-tools/install-rust.sh"
}
