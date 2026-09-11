#!/usr/bin/env bash
# Vérifie qu'aucun secret (clé API, jeton, mot de passe, clé privée, fichier de credentials)
# n'est présent dans les fichiers suivis par Git ou dans l'index.
# Usage : bash scripts/check-secrets.sh            (fichiers suivis + index)
#         bash scripts/check-secrets.sh --staged   (index seulement, pour le hook pre-commit)
# Code de retour : 0 si propre, 1 si un secret potentiel est détecté.
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

mode="${1:-all}"
if [ "$mode" = "--staged" ]; then
  files="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)"
else
  files="$(git ls-files 2>/dev/null; git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)"
  [ -n "$files" ] || files="$(find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './site/*' -not -path './build/out/*' | sed 's|^\./||')"
fi
files="$(printf '%s\n' "$files" | sort -u | grep -v '^$' || true)"
[ -n "$files" ] || { echo "Aucun fichier à vérifier."; exit 0; }

# 1. Noms de fichiers interdits
forbidden_names='(^|/)(\.env(\..*)?|.*\.pem|.*\.key|.*\.p12|.*\.pfx|.*\.jks|.*keystore.*|id_rsa.*|id_ed25519.*|.*\.token|google-services\.json|GoogleService-Info\.plist|.*firebase-adminsdk.*\.json|service-account.*\.json|credentials\.json|\.netrc|\.npmrc|\.pypirc|secrets?\.(ya?ml|json|txt))$'
bad_names="$(printf '%s\n' "$files" | grep -E "$forbidden_names" | grep -vE '^(docs/|.*\.md$)' || true)"

# 2. Motifs de secrets dans le contenu (un seul passage grep sur les fichiers texte)
patterns=(
  'AKIA[0-9A-Z]{16}'                                   # AWS access key
  'ghp_[A-Za-z0-9]{36}'                                # GitHub PAT
  'gho_[A-Za-z0-9]{36}'                                # GitHub OAuth
  'github_pat_[A-Za-z0-9_]{22,}'                       # GitHub fine-grained PAT
  'sk-(ant-|proj-)?[A-Za-z0-9_-]{20,}'                 # OpenAI / Anthropic
  'AIza[0-9A-Za-z_-]{35}'                              # Google API key
  'xox[baprs]-[0-9A-Za-z-]{10,}'                       # Slack
  'glpat-[A-Za-z0-9_-]{20,}'                           # GitLab PAT
  '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY'
  'eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}\.'     # JWT
  '(password|passwd|pwd|mot_de_passe|secret|api[_-]?key|token|client[_-]?secret)[[:space:]]*[=:][[:space:]]*["'"'"'][^"'"'"'[:space:]]{8,}["'"'"']'
)
grep_args=()
for p in "${patterns[@]}"; do grep_args+=(-e "$p"); done

# Fichiers texte à analyser (binaires et ce script exclus)
text_files="$(printf '%s\n' "$files" | grep -vE '\.(png|jpe?g|gif|ico|woff2?|ttf|otf|zip|gz|xz|iso|deb)$' | grep -v '^scripts/check-secrets.sh$' || true)"
hits=""
if [ -n "$text_files" ]; then
  # shellcheck disable=SC2086
  hits="$(printf '%s\n' "$text_files" | tr '\n' '\0' | xargs -0 grep -nEIH "${grep_args[@]}" -- 2>/dev/null \
    | grep -viE 'exemple|example|placeholder|<[A-Z_-]+>|\$\{?[A-Z_]+\}?|nos config set|passwd -d|passwd_tries|setRootPassword|doReusePassword|allowWeakPasswords|passwordRequirements|display_password|DisplayPassword|SetDisplayPasswordFunction|prompt|mot de passe demand|secret-scan' || true)"
fi

status=0
if [ -n "$bad_names" ]; then
  echo "✘ Fichiers sensibles détectés (ne doivent jamais être versionnés) :"
  printf '%s\n' "$bad_names" | sed 's/^/    /'
  status=1
fi
if [ -n "$hits" ]; then
  echo "✘ Motifs de secrets détectés :"
  printf '%s\n' "$hits" | sed 's/^/    /'
  status=1
fi
if [ "$status" -eq 0 ]; then
  echo "✔ Aucun secret détecté ($(printf '%s\n' "$files" | wc -l | tr -d ' ') fichiers vérifiés)."
else
  echo
  echo "Retirez le secret, remplacez-le par une variable d'environnement ou un fichier ignoré (.env, voir .gitignore),"
  echo "puis révoquez-le s'il a déjà été exposé. Voir docs/security/index.md."
fi
exit "$status"
