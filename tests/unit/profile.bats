#!/usr/bin/env bats
# Tests unitaires de nos profile (mode dry-run)

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  NOS="$ROOT/apps/nos-cli/bin/nos"
  export HOME="$(mktemp -d)"
  export XDG_CONFIG_HOME="$HOME/.config"
  export NOS_HOME="$HOME/.nos"
  export NO_COLOR=1
  export NOS_DRY_RUN=1
}

teardown() {
  rm -rf "$HOME"
}

@test "nos profile list affiche les 4 profils" {
  run bash "$NOS" profile list
  [ "$status" -eq 0 ]
  for p in dev bureautique education administration; do
    [[ "$output" == *"$p"* ]] || { echo "manque : $p"; return 1; }
  done
}

@test "nos profile show bureautique decrit le profil" {
  run bash "$NOS" profile show bureautique
  [ "$status" -eq 0 ]
  [[ "$output" == *"Bureautique"* ]]
  [[ "$output" == *"libreoffice"* ]]
}

@test "nos profile show inconnu echoue" {
  run bash "$NOS" profile show comptabilite-martienne
  [ "$status" -eq 1 ]
  [[ "$output" == *"Profil inconnu"* ]]
}

@test "nos profile apply education (dry-run) installe outils et applique le script" {
  run bash "$NOS" profile apply education
  [ "$status" -eq 0 ]
  [[ "$output" == *"apt-get install"* ]]
  [[ "$output" == *"texlive"* ]] || [[ "$output" == *"latex"* ]]
  [[ "$output" == *"education.sh"* ]]
  [[ "$output" == *"appliqué"* ]]
  run bash "$NOS" config get profiles
  [[ "$output" == *"education"* ]]
}

@test "nos profile apply --no-optimize n'execute pas le script" {
  run bash "$NOS" profile apply administration --no-optimize
  [ "$status" -eq 0 ]
  [[ "$output" != *"administration.sh"* ]]
}

@test "les profils appliques sont cumules sans doublon" {
  bash "$NOS" profile apply bureautique >/dev/null
  bash "$NOS" profile apply bureautique >/dev/null
  bash "$NOS" profile apply dev >/dev/null
  run bash "$NOS" config get profiles
  [ "$output" = "bureautique,dev" ]
}

@test "chaque outil liste dans un profil existe dans le catalogue" {
  for f in "$ROOT"/apps/nos-cli/share/profiles/*.profile; do
    tools="$(grep -E '^tools=' "$f" | cut -d= -f2-)"
    for t in $tools; do
      grep -qP "^${t}\t" "$ROOT/apps/nos-cli/share/catalog.tsv" || { echo "outil inconnu '$t' dans $(basename "$f")"; return 1; }
    done
  done
}

@test "chaque profil a un script d'optimisation" {
  for f in "$ROOT"/apps/nos-cli/share/profiles/*.profile; do
    id="$(basename "$f" .profile)"
    [ -f "$ROOT/scripts/profiles/$id.sh" ] || { echo "script manquant : scripts/profiles/$id.sh"; return 1; }
  done
}
