#!/usr/bin/env bash
# N-OS Doctor : diagnostic et réparation de l'environnement de développement
# Copyright (C) 2026 ICONEDOR, Burkina Faso
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Chaque vérification vit dans checks/<id>.sh et définit :
#   check_<id>()   → appelle doctor_result <ok|warn|fail> "message" ["conseil"]
#   repair_<id>()  → (optionnel) tente une réparation automatique
#   et s'enregistre avec : doctor_register <id> "Libellé" [catégorie]

DOCTOR_IDS=()
DOCTOR_LABELS=()
DOCTOR_CATEGORIES=()

# Résultats (remplis par doctor_result pendant l'exécution d'une vérification)
DOCTOR_R_STATUS=()
DOCTOR_R_MESSAGE=()
DOCTOR_R_HINT=()
DOCTOR_R_REPAIRED=()

_DOCTOR_CUR_STATUS=""
_DOCTOR_CUR_MESSAGE=""
_DOCTOR_CUR_HINT=""

doctor_register() {
  DOCTOR_IDS+=("$1")
  DOCTOR_LABELS+=("$2")
  DOCTOR_CATEGORIES+=("${3:-Général}")
}

doctor_result() {
  _DOCTOR_CUR_STATUS="$1"
  _DOCTOR_CUR_MESSAGE="${2:-}"
  _DOCTOR_CUR_HINT="${3:-}"
}

doctor_load_checks() {
  local f
  for f in "$NOS_DOCTOR_LIB"/checks/*.sh; do
    # shellcheck source=/dev/null
    source "$f"
  done
}

doctor_run_check() {
  local id="$1"
  _DOCTOR_CUR_STATUS="fail"; _DOCTOR_CUR_MESSAGE="vérification non exécutée"; _DOCTOR_CUR_HINT=""
  if declare -F "check_$id" >/dev/null; then
    "check_$id" || true
  else
    _DOCTOR_CUR_MESSAGE="fonction check_$id introuvable"
  fi
}

doctor_status_icon() {
  case "$1" in
    ok)   printf '%s✔%s' "$C_GREEN" "$C_RESET" ;;
    warn) printf '%s!%s' "$C_YELLOW" "$C_RESET" ;;
    fail) printf '%s✘%s' "$C_RED" "$C_RESET" ;;
    *)    printf '?' ;;
  esac
}

doctor_print_text() {
  local i n_ok=0 n_warn=0 n_fail=0 current_cat=""
  nos_banner
  printf '%sN-OS Doctor%s, %s, %s\n' "$C_BOLD" "$C_RESET" "$(nos_os_pretty)" "$(date '+%Y-%m-%d %H:%M')"
  for i in "${!DOCTOR_IDS[@]}"; do
    if [ "${DOCTOR_CATEGORIES[$i]}" != "$current_cat" ]; then
      current_cat="${DOCTOR_CATEGORIES[$i]}"
      printf '\n%s%s%s\n' "$C_GOLD" "$current_cat" "$C_RESET"
    fi
    printf '  [%s] %-22s %s' "$(doctor_status_icon "${DOCTOR_R_STATUS[$i]}")" "${DOCTOR_LABELS[$i]}" "${DOCTOR_R_MESSAGE[$i]}"
    [ "${DOCTOR_R_REPAIRED[$i]}" = "1" ] && printf ' %s(réparé)%s' "$C_GREEN" "$C_RESET"
    printf '\n'
    if [ "${DOCTOR_R_STATUS[$i]}" != "ok" ] && [ -n "${DOCTOR_R_HINT[$i]}" ]; then
      printf '      %s→ %s%s\n' "$C_DIM" "${DOCTOR_R_HINT[$i]}" "$C_RESET"
    fi
    case "${DOCTOR_R_STATUS[$i]}" in
      ok) n_ok=$((n_ok + 1)) ;; warn) n_warn=$((n_warn + 1)) ;; *) n_fail=$((n_fail + 1)) ;;
    esac
  done
  printf '\n%sRésumé :%s %s%d OK%s, %s%d avertissement(s)%s, %s%d échec(s)%s\n' \
    "$C_BOLD" "$C_RESET" "$C_GREEN" "$n_ok" "$C_RESET" "$C_YELLOW" "$n_warn" "$C_RESET" "$C_RED" "$n_fail" "$C_RESET"
  if [ "$n_fail" -gt 0 ] || [ "$n_warn" -gt 0 ]; then
    printf '%sConseil :%s nos doctor --repair pour tenter une réparation automatique.\n' "$C_DIM" "$C_RESET"
  fi
  printf '\n'
}

doctor_print_json() {
  local i n_ok=0 n_warn=0 n_fail=0
  for i in "${!DOCTOR_IDS[@]}"; do
    case "${DOCTOR_R_STATUS[$i]}" in
      ok) n_ok=$((n_ok + 1)) ;; warn) n_warn=$((n_warn + 1)) ;; *) n_fail=$((n_fail + 1)) ;;
    esac
  done
  printf '{\n'
  printf '  "tool": "nos-doctor",\n'
  printf '  "nos_version": "%s",\n' "$(nos_json_escape "$(nos_version)")"
  printf '  "system": "%s",\n' "$(nos_json_escape "$(nos_os_pretty)")"
  printf '  "date": "%s",\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf '  "summary": {"ok": %d, "warn": %d, "fail": %d, "total": %d},\n' "$n_ok" "$n_warn" "$n_fail" "${#DOCTOR_IDS[@]}"
  printf '  "checks": [\n'
  for i in "${!DOCTOR_IDS[@]}"; do
    printf '    {"id": "%s", "label": "%s", "category": "%s", "status": "%s", "message": "%s", "hint": "%s", "repaired": %s}' \
      "$(nos_json_escape "${DOCTOR_IDS[$i]}")" \
      "$(nos_json_escape "${DOCTOR_LABELS[$i]}")" \
      "$(nos_json_escape "${DOCTOR_CATEGORIES[$i]}")" \
      "${DOCTOR_R_STATUS[$i]}" \
      "$(nos_json_escape "${DOCTOR_R_MESSAGE[$i]}")" \
      "$(nos_json_escape "${DOCTOR_R_HINT[$i]}")" \
      "$([ "${DOCTOR_R_REPAIRED[$i]}" = "1" ] && printf 'true' || printf 'false')"
    [ "$i" -lt $((${#DOCTOR_IDS[@]} - 1)) ] && printf ','
    printf '\n'
  done
  printf '  ]\n}\n'
}

doctor_html_escape() {
  local s="$1"
  s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"; s="${s//\"/&quot;}"
  printf '%s' "$s"
}

doctor_print_html() {
  local i n_ok=0 n_warn=0 n_fail=0
  for i in "${!DOCTOR_IDS[@]}"; do
    case "${DOCTOR_R_STATUS[$i]}" in
      ok) n_ok=$((n_ok + 1)) ;; warn) n_warn=$((n_warn + 1)) ;; *) n_fail=$((n_fail + 1)) ;;
    esac
  done
  cat <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Rapport N-OS Doctor</title>
<style>
  :root { --red:#D62828; --gold:#D4AF37; --green:#198754; --black:#111111; --white:#FFFFFF; }
  body { font-family: Inter, Manrope, Roboto, system-ui, sans-serif; margin: 0; padding: 32px 16px; background: #f7f7f7; color: var(--black); }
  main { max-width: 900px; margin: 0 auto; background: var(--white); border-radius: 16px; padding: 32px; box-shadow: 0 2px 12px rgba(0,0,0,.06); }
  h1 { font-family: Poppins, Montserrat, sans-serif; margin: 0 0 4px; color: var(--red); }
  .meta { color: #666; margin-bottom: 24px; }
  .summary { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 24px; }
  .pill { padding: 8px 16px; border-radius: 999px; font-weight: 600; color: #fff; }
  .ok { background: var(--green); } .warn { background: var(--gold); color: var(--black); } .fail { background: var(--red); }
  table { width: 100%; border-collapse: collapse; }
  th, td { text-align: left; padding: 10px 8px; border-bottom: 1px solid #eee; vertical-align: top; }
  th { color: #666; font-weight: 600; font-size: 13px; }
  .status { font-weight: 700; }
  .status.ok { color: var(--green); background: none; } .status.warn { color: #a3861a; background: none; } .status.fail { color: var(--red); background: none; }
  .hint { color: #666; font-size: 13px; }
  footer { margin-top: 32px; color: #888; font-size: 13px; text-align: center; }
</style>
</head>
<body>
<main>
<h1>N-OS Doctor</h1>
<div class="meta">$(doctor_html_escape "$(nos_os_pretty)") · N-OS $(doctor_html_escape "$(nos_version)") · $(date '+%d/%m/%Y %H:%M')</div>
<div class="summary">
  <span class="pill ok">$n_ok OK</span>
  <span class="pill warn">$n_warn avertissement(s)</span>
  <span class="pill fail">$n_fail échec(s)</span>
</div>
<table>
<thead><tr><th>État</th><th>Vérification</th><th>Résultat</th></tr></thead>
<tbody>
EOF
  for i in "${!DOCTOR_IDS[@]}"; do
    local st="${DOCTOR_R_STATUS[$i]}" label
    case "$st" in ok) label="OK" ;; warn) label="Attention" ;; *) label="Échec" ;; esac
    printf '<tr><td class="status %s">%s</td><td><strong>%s</strong><br><span class="hint">%s</span></td><td>%s' \
      "$st" "$label" "$(doctor_html_escape "${DOCTOR_LABELS[$i]}")" "$(doctor_html_escape "${DOCTOR_CATEGORIES[$i]}")" "$(doctor_html_escape "${DOCTOR_R_MESSAGE[$i]}")"
    [ "$st" != "ok" ] && [ -n "${DOCTOR_R_HINT[$i]}" ] && printf '<br><span class="hint">→ %s</span>' "$(doctor_html_escape "${DOCTOR_R_HINT[$i]}")"
    printf '</td></tr>\n'
  done
  cat <<EOF
</tbody>
</table>
<footer><a href="https://naabiga.com" style="color:#D62828">naabiga.com</a> · Naabiga OS : ICONEDOR × Université Aube Nouvelle (Bobo-Dioulasso) · Build Faster. Create Smarter.</footer>
</main>
</body>
</html>
EOF
}

doctor_usage() {
  cat <<EOF
Usage : nos doctor [options]

Options :
  --repair          Tenter de réparer automatiquement les problèmes détectés
  --json            Sortie JSON (pour N-OS Center, CI, support)
  --export [FICH]   Générer un rapport HTML (défaut : ./nos-doctor-report.html)
  --check ID        N'exécuter qu'une vérification (ex. flutter, java, docker)
  --list            Lister les vérifications disponibles
  --no-fail         Toujours retourner 0 (utile en script)
  -h, --help        Cette aide

Code de retour : 0 si aucun échec, 1 sinon.
EOF
}

doctor_main() {
  local do_repair=0 format="text" export_file="" only="" no_fail=0 do_list=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --repair) do_repair=1 ;;
      --json) format="json" ;;
      --export)
        format="html"
        if [ -n "${2:-}" ] && [[ "${2}" != --* ]]; then export_file="$2"; shift; else export_file="nos-doctor-report.html"; fi
        ;;
      --check) only="${2:-}"; [ -n "$only" ] || nos_die "--check nécessite un identifiant"; shift ;;
      --list) do_list=1 ;;
      --no-fail) no_fail=1 ;;
      -h|--help) doctor_usage; return 0 ;;
      *)
        # "nos doctor flutter" == "nos doctor --check flutter"
        if [[ "$1" != -* ]]; then only="$1"; else nos_err "Option inconnue : $1"; doctor_usage; return 2; fi
        ;;
    esac
    shift
  done

  doctor_load_checks

  if [ "$do_list" = 1 ]; then
    local i
    for i in "${!DOCTOR_IDS[@]}"; do
      printf '%-14s %-24s %s\n' "${DOCTOR_IDS[$i]}" "${DOCTOR_LABELS[$i]}" "${DOCTOR_CATEGORIES[$i]}"
    done
    return 0
  fi

  if [ -n "$only" ]; then
    local found=0 i
    local -a ids=() labels=() cats=()
    for i in "${!DOCTOR_IDS[@]}"; do
      if [ "${DOCTOR_IDS[$i]}" = "$only" ]; then
        ids+=("${DOCTOR_IDS[$i]}"); labels+=("${DOCTOR_LABELS[$i]}"); cats+=("${DOCTOR_CATEGORIES[$i]}"); found=1
      fi
    done
    [ "$found" = 1 ] || nos_die "Vérification inconnue : $only (nos doctor --list)"
    DOCTOR_IDS=("${ids[@]}"); DOCTOR_LABELS=("${labels[@]}"); DOCTOR_CATEGORIES=("${cats[@]}")
  fi

  local i id
  for i in "${!DOCTOR_IDS[@]}"; do
    id="${DOCTOR_IDS[$i]}"
    doctor_run_check "$id"
    DOCTOR_R_REPAIRED[i]=0
    if [ "$do_repair" = 1 ] && [ "$_DOCTOR_CUR_STATUS" != "ok" ] && declare -F "repair_$id" >/dev/null; then
      [ "$format" = "text" ] && nos_info "Réparation : ${DOCTOR_LABELS[$i]}…"
      if "repair_$id"; then
        doctor_run_check "$id"
        [ "$_DOCTOR_CUR_STATUS" = "ok" ] && DOCTOR_R_REPAIRED[i]=1
      fi
    fi
    DOCTOR_R_STATUS[i]="$_DOCTOR_CUR_STATUS"
    DOCTOR_R_MESSAGE[i]="$_DOCTOR_CUR_MESSAGE"
    DOCTOR_R_HINT[i]="$_DOCTOR_CUR_HINT"
  done

  case "$format" in
    json) doctor_print_json ;;
    html)
      doctor_print_html > "$export_file"
      nos_ok "Rapport HTML : $export_file"
      ;;
    *) doctor_print_text ;;
  esac

  [ "$no_fail" = 1 ] && return 0
  for i in "${!DOCTOR_IDS[@]}"; do
    [ "${DOCTOR_R_STATUS[$i]}" = "fail" ] && return 1
  done
  return 0
}
