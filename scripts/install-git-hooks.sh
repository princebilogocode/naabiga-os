#!/usr/bin/env bash
# Installe les hooks Git du projet (pre-commit : scan de secrets + shellcheck sur les scripts modifiés)
# Usage : bash scripts/install-git-hooks.sh   (ou : make hooks)
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$ROOT/.git/hooks"
[ -d "$HOOKS" ] || { echo "Pas de dépôt Git dans $ROOT"; exit 1; }

cat > "$HOOKS/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Naabiga OS : hook pre-commit
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel)"
bash "$ROOT/scripts/check-secrets.sh" --staged || exit 1
if command -v shellcheck >/dev/null 2>&1; then
  files="$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.sh$|/nos$|\.hook\.chroot$|iso/auto/config$' || true)"
  if [ -n "$files" ]; then
    # shellcheck disable=SC2086
    shellcheck -x -s bash $files || exit 1
  fi
fi
exit 0
EOF
chmod +x "$HOOKS/pre-commit"
echo "Hook pre-commit installé ($HOOKS/pre-commit)."
