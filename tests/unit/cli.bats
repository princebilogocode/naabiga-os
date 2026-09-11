#!/usr/bin/env bats
# Tests unitaires de la CLI nos

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

@test "nos version affiche la version du fichier VERSION" {
  run bash "$NOS" version --short
  [ "$status" -eq 0 ]
  [ "$output" = "$(tr -d '[:space:]' < "$ROOT/VERSION")" ]
}

@test "nos --version et -v sont des alias" {
  run bash "$NOS" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"Naabiga OS"* ]]
  run bash "$NOS" -v
  [ "$status" -eq 0 ]
}

@test "nos help liste les commandes" {
  run bash "$NOS" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"sdk"* ]]
  [[ "$output" == *"ai"* ]]
}

@test "nos sans argument affiche l'aide" {
  run bash "$NOS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "commande inconnue retourne 2" {
  run bash "$NOS" commande-inexistante
  [ "$status" -eq 2 ]
  [[ "$output" == *"Commande inconnue"* ]]
}

@test "nos install --list affiche le catalogue" {
  run bash "$NOS" install --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"flutter"* ]]
  [[ "$output" == *"android-studio"* ]]
  [[ "$output" == *"docker"* ]]
}

@test "nos install (dry-run) construit la commande apt" {
  run bash "$NOS" install sqlite
  [ "$status" -eq 0 ]
  [[ "$output" == *"[dry-run]"* ]]
  [[ "$output" == *"apt-get install"* ]]
  [[ "$output" == *"sqlite3"* ]]
}

@test "nos install outil inconnu echoue" {
  run bash "$NOS" install outil-qui-n-existe-pas
  [ "$status" -eq 1 ]
  [[ "$output" == *"Outil inconnu"* ]]
}

@test "nos config set/get" {
  run bash "$NOS" config set lang fr
  [ "$status" -eq 0 ]
  run bash "$NOS" config get lang
  [ "$status" -eq 0 ]
  [ "$output" = "fr" ]
  run bash "$NOS" config set lang en
  run bash "$NOS" config get lang
  [ "$output" = "en" ]
}

@test "nos config get cle absente retourne la valeur vide" {
  run bash "$NOS" config get cle-absente
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "nos info s'execute" {
  run bash "$NOS" info
  [ "$status" -eq 0 ]
  [[ "$output" == *"Système"* ]]
}

@test "nos update (dry-run) n'execute rien" {
  run bash "$NOS" update --system
  [ "$status" -eq 0 ]
}

@test "le catalogue est un TSV valide a 6 colonnes" {
  while IFS= read -r line; do
    [[ "$line" == \#* ]] && continue
    [ -z "$line" ] && continue
    n="$(printf '%s' "$line" | awk -F'\t' '{print NF}')"
    [ "$n" -eq 6 ] || { echo "ligne invalide : $line"; return 1; }
  done < "$ROOT/apps/nos-cli/share/catalog.tsv"
}
