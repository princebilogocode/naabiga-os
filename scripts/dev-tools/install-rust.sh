#!/usr/bin/env bash
# Installe Rust (rustc, cargo) via rustup, dans l'espace utilisateur
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

if command -v rustc >/dev/null 2>&1; then
  echo "Rust est déjà installé : $(rustc --version)"
  exit 0
fi

command -v curl >/dev/null 2>&1 || { echo "curl est requis"; exit 1; }
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

mkdir -p "$HOME/.nos"
grep -qxF 'export PATH="$HOME/.cargo/bin:$PATH"' "$HOME/.nos/env.sh" 2>/dev/null \
  || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.nos/env.sh"

echo "Rust installé. Rechargez votre shell : source ~/.nos/env.sh"
