#!/usr/bin/env bats
# Tests unitaires de N-OS Doctor

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  NOS="$ROOT/apps/nos-cli/bin/nos"
  export HOME="$(mktemp -d)"
  export NO_COLOR=1
  export NOS_DRY_RUN=1
}

teardown() {
  rm -rf "$HOME"
}

@test "nos doctor --list liste les verifications attendues" {
  run bash "$NOS" doctor --list
  [ "$status" -eq 0 ]
  for id in git java android_sdk adb flutter dart node python docker path env_vars vscode disk security ai; do
    [[ "$output" == *"$id"* ]] || { echo "manque : $id"; return 1; }
  done
}

@test "nos doctor --json produit un JSON valide" {
  run bash "$NOS" doctor --json --no-fail
  [ "$status" -eq 0 ]
  py=""
  for cand in python3 python; do
    "$cand" -c 'pass' >/dev/null 2>&1 && { py="$cand"; break; }
  done
  if [ -n "$py" ]; then
    printf '%s' "$output" | "$py" -c 'import sys, json; d = json.load(sys.stdin); assert d["tool"] == "nos-doctor"; assert len(d["checks"]) >= 15; assert d["summary"]["total"] == len(d["checks"])'
  elif command -v jq >/dev/null; then
    printf '%s' "$output" | jq -e '.tool == "nos-doctor" and (.checks | length) >= 15' >/dev/null
  else
    [[ "$output" == *'"tool": "nos-doctor"'* ]]
  fi
}

@test "nos doctor --check git n'execute qu'une verification" {
  run bash "$NOS" doctor --check git --json --no-fail
  [ "$status" -eq 0 ]
  [[ "$output" == *'"id": "git"'* ]]
  [[ "$output" != *'"id": "docker"'* ]]
}

@test "nos doctor flutter equivaut a --check flutter" {
  run bash "$NOS" doctor flutter --json --no-fail
  [ "$status" -eq 0 ]
  [[ "$output" == *'"id": "flutter"'* ]]
  [[ "$output" == *'"total": 1'* ]]
}

@test "nos doctor --check inconnu echoue" {
  run bash "$NOS" doctor --check verification-inconnue
  [ "$status" -eq 1 ]
  [[ "$output" == *"Vérification inconnue"* ]]
}

@test "nos doctor --export genere un rapport HTML" {
  run bash "$NOS" doctor --export "$HOME/rapport.html" --no-fail
  [ "$status" -eq 0 ]
  [ -f "$HOME/rapport.html" ]
  grep -q '<title>Rapport N-OS Doctor</title>' "$HOME/rapport.html"
  grep -q 'Naabiga OS' "$HOME/rapport.html"
}

@test "nos doctor --no-fail retourne toujours 0" {
  run bash "$NOS" doctor --no-fail
  [ "$status" -eq 0 ]
}

@test "nos doctor sans --no-fail retourne 0 ou 1" {
  run bash "$NOS" doctor
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" == *"Résumé"* ]]
}

@test "nos repair est un alias de doctor --repair (dry-run)" {
  run bash "$NOS" repair --check nos_env --no-fail
  [ "$status" -eq 0 ]
  [ -f "$HOME/.nos/env.sh" ]
}

@test "la reparation nos_env cree ~/.nos/env.sh et l'ajoute au .bashrc" {
  touch "$HOME/.bashrc"
  run bash "$NOS" doctor --repair --check nos_env --json --no-fail
  [ "$status" -eq 0 ]
  [ -f "$HOME/.nos/env.sh" ]
  grep -q '.nos/env.sh' "$HOME/.bashrc"
  [[ "$output" == *'"repaired": true'* ]]
}

@test "chaque fichier de verification declare check_<id> et doctor_register" {
  for f in "$ROOT"/apps/nos-doctor/lib/checks/*.sh; do
    grep -q '^doctor_register ' "$f" || { echo "pas de doctor_register dans $f"; return 1; }
    id="$(grep '^doctor_register ' "$f" | awk '{print $2}')"
    grep -q "^check_${id}()" "$f" || { echo "pas de check_${id} dans $f"; return 1; }
  done
}
