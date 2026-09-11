#!/usr/bin/env bash
# Tests d'intégration : installation de la CLI dans un DESTDIR temporaire,
# cohérence des fichiers du dépôt, build des paquets si dpkg-deb est disponible.
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export NO_COLOR=1 NOS_DRY_RUN=1
PASS=0; FAIL=0

ok()   { PASS=$((PASS + 1)); printf '  \e[32m✔\e[0m %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  \e[31m✘\e[0m %s\n' "$1"; }
check() { if "$@" >/dev/null 2>&1; then ok "${*:2}"; else fail "${*:2}"; fi; }

echo "== Installation dans DESTDIR"
DESTDIR="$TMP/root" PREFIX=/usr bash "$ROOT/build/install-cli.sh"
[ -x "$TMP/root/usr/bin/nos" ] && ok "bin/nos installé" || fail "bin/nos installé"
[ -f "$TMP/root/usr/lib/nos/lib/core.sh" ] && ok "lib/core.sh installé" || fail "lib/core.sh installé"
[ -f "$TMP/root/usr/lib/nos/doctor/doctor.sh" ] && ok "doctor installé" || fail "doctor installé"
[ -f "$TMP/root/usr/share/nos/catalog.tsv" ] && ok "catalogue installé" || fail "catalogue installé"
[ -f "$TMP/root/etc/profile.d/nos.sh" ] && ok "profile.d/nos.sh installé" || fail "profile.d/nos.sh installé"
n_checks_src="$(find "$ROOT/apps/nos-doctor/lib/checks" -name "*.sh" | wc -l)"
n_checks_dst="$(find "$TMP/root/usr/lib/nos/doctor/checks" -name "*.sh" | wc -l)"
[ "$n_checks_src" -eq "$n_checks_dst" ] && ok "toutes les vérifications copiées ($n_checks_dst)" || fail "vérifications copiées"

echo "== CLI installée (mode installed simulé)"
# On simule /usr/lib/nos en exécutant une copie du binaire hors du dépôt
mkdir -p "$TMP/fake/usr/bin"
cp "$TMP/root/usr/bin/nos" "$TMP/fake/usr/bin/nos"
if ! out="$(HOME="$TMP/home" NOS_SHARE="$TMP/root/usr/share/nos" bash "$TMP/fake/usr/bin/nos" version 2>&1)"; then
  # Attendu : /usr/lib/nos n'existe pas sur la machine de test
  [[ "$out" == *"/usr/lib/nos/lib/core.sh"* ]] && ok "mode installé cherche bien /usr/lib/nos" || fail "mode installé : $out"
else
  ok "mode installé fonctionne (nos réellement installé sur cette machine)"
fi

echo "== Désinstallation"
DESTDIR="$TMP/root" PREFIX=/usr bash "$ROOT/build/install-cli.sh" --uninstall
[ ! -e "$TMP/root/usr/bin/nos" ] && ok "désinstallation propre" || fail "désinstallation propre"

echo "== Cohérence du dépôt"
[ "$(tr -d '[:space:]' < "$ROOT/VERSION")" != "" ] && ok "VERSION non vide" || fail "VERSION non vide"
grep -q "$(tr -d '[:space:]' < "$ROOT/VERSION")" "$ROOT/CHANGELOG.md" && ok "CHANGELOG mentionne la version" || fail "CHANGELOG mentionne la version"
for f in README.md LICENSE CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md mkdocs.yml; do
  [ -f "$ROOT/$f" ] && ok "$f présent" || fail "$f présent"
done
for d in docs branding build iso packages desktop installer apps scripts tests .github; do
  [ -d "$ROOT/$d" ] && ok "dossier $d/ présent" || fail "dossier $d/ présent"
done
# Chaque outil "script" du catalogue doit avoir son script
while IFS=$'\t' read -r id _ _ method spec _; do
  [[ "$id" == \#* || -z "$id" ]] && continue
  if [ "$method" = "script" ]; then
    [ -f "$ROOT/scripts/dev-tools/$spec" ] && ok "script $spec ($id)" || fail "script $spec ($id) manquant"
  fi
done < "$ROOT/apps/nos-cli/share/catalog.tsv"
# Les listes de paquets live-build ne doivent pas contenir de doublons
if [ -d "$ROOT/iso/config/package-lists" ]; then
  dups="$(cat "$ROOT"/iso/config/package-lists/*.list.chroot | grep -v '^#' | grep -v '^$' | sort | uniq -d || true)"
  [ -z "$dups" ] && ok "listes de paquets sans doublon" || fail "doublons : $dups"
fi

echo "== Paquets .deb"
if command -v dpkg-deb >/dev/null 2>&1; then
  OUT="$TMP/pkgs" bash "$ROOT/build/build-packages.sh" >/dev/null && ok "build-packages.sh" || fail "build-packages.sh"
  debs="$(find "$TMP/pkgs" -name '*.deb' -printf '%f ' 2>/dev/null)"
  [ -n "$debs" ] && ok "paquets générés : $debs" || fail "paquets générés"
else
  echo "  (dpkg-deb absent : build des paquets ignoré)"
fi

echo
echo "Résultat : $PASS réussi(s), $FAIL échec(s)"
[ "$FAIL" -eq 0 ]
