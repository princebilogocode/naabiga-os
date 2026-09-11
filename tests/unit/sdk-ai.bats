#!/usr/bin/env bats
# Tests unitaires de N-OS SDK Manager et AI Hub (mode dry-run)

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  NOS="$ROOT/apps/nos-cli/bin/nos"
  export HOME="$(mktemp -d)"
  export XDG_CONFIG_HOME="$HOME/.config"
  export NOS_HOME="$HOME/.nos"
  export NOS_SDK_DIR="$HOME/.nos/sdk"
  export NO_COLOR=1
  export NOS_DRY_RUN=1
}

teardown() {
  rm -rf "$HOME"
}

# Les liens symboliques sont indispensables au SDK Manager ; absents sur certains environnements (Git Bash Windows)
require_symlinks() {
  ln -s "$HOME" "$HOME/.symlink-test" 2>/dev/null && [ -L "$HOME/.symlink-test" ] || skip "liens symboliques non supportés ici"
  rm -f "$HOME/.symlink-test"
}

@test "nos sdk list affiche les 4 SDK geres" {
  run bash "$NOS" sdk list
  [ "$status" -eq 0 ]
  [[ "$output" == *"flutter"* ]]
  [[ "$output" == *"java"* ]]
  [[ "$output" == *"node"* ]]
  [[ "$output" == *"android"* ]]
}

@test "nos sdk install sdk-inconnu echoue" {
  run bash "$NOS" sdk install cobol 1
  [ "$status" -eq 1 ]
  [[ "$output" == *"SDK inconnu"* ]]
}

@test "nos sdk use version non installee echoue" {
  run bash "$NOS" sdk use java 99
  [ "$status" -eq 1 ]
  [[ "$output" == *"Version non installée"* ]]
}

@test "nos sdk use active une version et ecrit ~/.nos/env.sh" {
  require_symlinks
  mkdir -p "$NOS_SDK_DIR/java/17/bin"
  run bash "$NOS" sdk use java 17
  [ "$status" -eq 0 ]
  [ -L "$NOS_SDK_DIR/java/current" ]
  [ "$(readlink "$NOS_SDK_DIR/java/current")" = "17" ]
  grep -q 'JAVA_HOME' "$HOME/.nos/env.sh"
  run bash "$NOS" sdk current java
  [[ "$output" == *"17"* ]]
}

@test "nos sdk use sans version prend la plus recente" {
  require_symlinks
  mkdir -p "$NOS_SDK_DIR/node/20.11.0" "$NOS_SDK_DIR/node/22.3.0"
  run bash "$NOS" sdk use node
  [ "$status" -eq 0 ]
  [ "$(readlink "$NOS_SDK_DIR/node/current")" = "22.3.0" ]
}

@test "nos sdk remove supprime la version et le lien current" {
  require_symlinks
  mkdir -p "$NOS_SDK_DIR/flutter/stable/bin"
  bash "$NOS" sdk use flutter stable
  export NOS_DRY_RUN=0
  run bash "$NOS" sdk remove flutter stable
  [ "$status" -eq 0 ]
  [ ! -d "$NOS_SDK_DIR/flutter/stable" ]
  [ ! -L "$NOS_SDK_DIR/flutter/current" ]
}

@test "nos sdk install flutter (dry-run) clone le depot" {
  run bash "$NOS" sdk install flutter stable
  [ "$status" -eq 0 ]
  [[ "$output" == *"git clone"* ]]
  [[ "$output" == *"flutter/flutter"* ]]
}

@test "nos ai list affiche les assistants" {
  run bash "$NOS" ai list
  [ "$status" -eq 0 ]
  for t in claude gemini ollama aider opencode continue copilot; do
    [[ "$output" == *"$t"* ]] || { echo "manque : $t"; return 1; }
  done
}

@test "nos ai install assistant inconnu echoue" {
  run bash "$NOS" ai install skynet
  [ "$status" -eq 1 ]
  [[ "$output" == *"Assistant inconnu"* ]]
}

@test "nos ai install claude (dry-run) utilise npm" {
  if ! command -v npm >/dev/null; then skip "npm absent"; fi
  run bash "$NOS" ai install claude
  [ "$status" -eq 0 ]
  [[ "$output" == *"npm install -g @anthropic-ai/claude-code"* ]]
}

@test "nos ai install ollama (dry-run) utilise le script officiel" {
  run bash "$NOS" ai install ollama
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama.com/install.sh"* ]]
}
