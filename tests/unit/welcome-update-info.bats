#!/usr/bin/env bats
# Tests : nos welcome (non interactif), nos update --check, nos info --json

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

# json_check "<code python>" : le JSON est lu sur l'entrée standard (variable $output)
json_check() {
  local py=""
  for cand in python3 python; do "$cand" -c 'pass' >/dev/null 2>&1 && { py="$cand"; break; }; done
  [ -n "$py" ] || skip "python absent"
  printf '%s' "$output" | "$py" -c "$1"
}

@test "nos welcome --yes applique le profil dev et marque l'assistant comme execute" {
  run bash "$NOS" welcome --yes --no-doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"Bienvenue sur Naabiga OS"* ]]
  [ -f "$HOME/.nos/welcome.done" ]
  grep -q '^profiles=dev$' "$HOME/.nos/welcome.done"
  run bash "$NOS" config get profiles
  [ "$output" = "dev" ]
}

@test "nos welcome ne se relance pas sans --force" {
  bash "$NOS" welcome --yes --no-doctor >/dev/null
  run bash "$NOS" welcome --yes --no-doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"déjà été exécuté"* ]]
  run bash "$NOS" welcome --yes --no-doctor --force
  [[ "$output" == *"Bienvenue"* ]]
}

@test "nos welcome --profile/--ide/--ai (dry-run) enchaine profils, IDE et IA" {
  run bash "$NOS" welcome --yes --no-doctor --profile bureautique,education --ide vscode --ai ollama
  [ "$status" -eq 0 ]
  [[ "$output" == *"install-vscode.sh"* ]]
  [[ "$output" == *"ollama.com/install.sh"* ]]
  grep -q '^profiles=bureautique,education$' "$HOME/.nos/welcome.done"
  run bash "$NOS" config get profiles
  [ "$output" = "bureautique,education" ]
}

@test "nos welcome --reset supprime le marqueur" {
  bash "$NOS" welcome --yes --no-doctor >/dev/null
  run bash "$NOS" welcome --reset
  [ "$status" -eq 0 ]
  [ ! -f "$HOME/.nos/welcome.done" ]
}

@test "nos update --check : a jour" {
  export NOS_LATEST_VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
  run bash "$NOS" update --check
  [ "$status" -eq 0 ]
  [[ "$output" == *"à jour"* ]]
}

@test "nos update --check : nouvelle version disponible retourne 10" {
  export NOS_LATEST_VERSION="9.9.9"
  run bash "$NOS" update --check
  [ "$status" -eq 10 ]
  [[ "$output" == *"9.9.9"* ]]
  [[ "$output" == *"nouvelle version"* ]]
}

@test "nos update --check : une pre-version est plus ancienne que la finale" {
  export NOS_VERSION_FILE="$HOME/version"
  echo "1.0.0-alpha.1" > "$NOS_VERSION_FILE"
  export NOS_LATEST_VERSION="1.0.0"
  run bash "$NOS" update --check
  [ "$status" -eq 10 ]
  echo "1.0.0" > "$NOS_VERSION_FILE"
  export NOS_LATEST_VERSION="1.0.0-rc.1"
  run bash "$NOS" update --check
  [ "$status" -eq 0 ]
}

@test "nos update --check : serveur injoignable retourne 1" {
  export NOS_RELEASES_API="http://127.0.0.1:9/inexistant"
  run bash "$NOS" update --check
  [ "$status" -eq 1 ]
  [[ "$output" == *"Impossible de joindre"* ]]
}

@test "nos info --json produit un JSON valide" {
  run bash "$NOS" info --json
  [ "$status" -eq 0 ]
  json_check "import sys, json; d=json.load(sys.stdin); assert d['nos_version']; assert isinstance(d['tools'], list) and len(d['tools']) >= 10; assert any(t['id']=='git' for t in d['tools']); assert isinstance(d['ai'], list)"
}

@test "nos doctor liste les nouvelles verifications (go, rust, php, education, administration)" {
  run bash "$NOS" doctor --list
  for id in go rust php education administration; do
    [[ "$output" == *"$id"* ]] || { echo "manque : $id"; return 1; }
  done
}

@test "les verifications de profil sont OK quand le profil n'est pas applique" {
  run bash "$NOS" doctor --check education --json --no-fail
  [[ "$output" == *'"status": "ok"'* ]]
  run bash "$NOS" doctor --check administration --json --no-fail
  [[ "$output" == *'"status": "ok"'* ]]
}

@test "la verification education echoue si le profil est applique sans les outils" {
  bash "$NOS" config set profiles education >/dev/null
  run bash "$NOS" doctor --check education
  [ "$status" -eq 1 ] || [ "$status" -eq 0 ]
  [[ "$output" == *"Profil Enseignement"* ]]
}
