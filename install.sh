#!/usr/bin/env bash
# Jobash interactive / non-interactive installer.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
# shellcheck source=lib/features.sh
source "$ROOT/lib/features.sh"
# shellcheck source=lib/bashrc.sh
source "$ROOT/lib/bashrc.sh"
# shellcheck source=lib/install.sh
source "$ROOT/lib/install.sh"
# shellcheck source=lib/ui.sh
source "$ROOT/lib/ui.sh"
jobash_ui_init

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Interactive (no flags): menu — all | choose | example

Options:
  --all                 Install every feature
  --features LIST       Install comma-separated feature ids (e.g. count)
  --example ID          Run a feature example (no install)
  --prefix DIR          Install prefix (default: ~/.jobash)
  --bashrc FILE         bashrc path (default: ~/.bashrc)
  --uninstall           Full cleanup (same as ./uninstall.sh --all)
  -h, --help            Show this help

See also: ./uninstall.sh for interactive / selective removal.
EOF
}

PREFIX="${JOBASH_PREFIX:-$HOME/.jobash}"
BASHRC="${JOBASH_BASHRC:-$HOME/.bashrc}"
MODE=""
FEATURES_CSV=""
EXAMPLE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      MODE="all"
      shift
      ;;
    --features)
      MODE="features"
      FEATURES_CSV="${2:-}"
      [[ -n "$FEATURES_CSV" ]] || jobash_die "--features requires a value"
      shift 2
      ;;
    --example)
      MODE="example"
      EXAMPLE_ID="${2:-}"
      [[ -n "$EXAMPLE_ID" ]] || jobash_die "--example requires a feature id"
      shift 2
      ;;
    --prefix)
      PREFIX="${2:-}"
      [[ -n "$PREFIX" ]] || jobash_die "--prefix requires a directory"
      shift 2
      ;;
    --bashrc)
      BASHRC="${2:-}"
      [[ -n "$BASHRC" ]] || jobash_die "--bashrc requires a file path"
      shift 2
      ;;
    --uninstall)
      MODE="uninstall"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      jobash_die "unknown option: $1 (try --help)"
      ;;
  esac
done

jobash_features_discover "$ROOT"
((${#JOBASH_FEATURE_IDS[@]} > 0)) || jobash_die "no features found under features/"

jobash_parse_csv() {
  local csv="$1"
  local -a out=()
  local part
  IFS=',' read -ra out <<<"$csv"
  FEATURE_SELECTION=()
  for part in "${out[@]}"; do
    part="${part#"${part%%[![:space:]]*}"}"
    part="${part%"${part##*[![:space:]]}"}"
    [[ -n "$part" ]] || continue
    FEATURE_SELECTION+=("$part")
  done
  ((${#FEATURE_SELECTION[@]} > 0)) || jobash_die "empty feature list"
}

jobash_is_back() {
  case "${1,,}" in
    0|b|back|q|quit) return 0 ;;
    *) return 1 ;;
  esac
}

jobash_is_blank() {
  [[ -z "${1//[[:space:]]/}" ]]
}

jobash_do_install_all() {
  jobash_features_require_ids "$ROOT" "${JOBASH_FEATURE_IDS[@]}"
  jobash_install_features "$ROOT" "$PREFIX" "$BASHRC" "${JOBASH_FEATURE_IDS[@]}"
}

jobash_do_install_selected() {
  jobash_features_require_ids "$ROOT" "${FEATURE_SELECTION[@]}"
  jobash_install_features "$ROOT" "$PREFIX" "$BASHRC" "${FEATURE_SELECTION[@]}"
}

jobash_print_features() {
  local with_desc="${1:-0}" i=1 id meta desc
  printf '%s\n' "${JOBASH_UI_BOLD}Available features${JOBASH_UI_RESET}"
  jobash_ui_sep
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    if [[ "$with_desc" == "1" ]]; then
      meta="$(jobash_feature_meta_path "$ROOT" "$id")"
      desc="$(jobash_feature_meta_get "$meta" description 2>/dev/null || true)"
      jobash_ui_menu_item "$i" "$id" "— ${desc:-}"
    else
      jobash_ui_menu_item "$i" "$id"
    fi
    i=$((i + 1))
  done
  jobash_ui_menu_item "0" "back" "— previous menu"
}

# Resolve number or id → FEATURE_ID.
# Returns 0 on ok, 1 on back, 2 on invalid.
jobash_resolve_feature_token() {
  local token="$1" idx
  FEATURE_ID=""
  if jobash_is_back "$token"; then
    return 1
  fi
  if [[ "$token" =~ ^[0-9]+$ ]]; then
    idx=$((token - 1))
    if ((idx < 0 || idx >= ${#JOBASH_FEATURE_IDS[@]})); then
      return 2
    fi
    FEATURE_ID="${JOBASH_FEATURE_IDS[$idx]}"
  else
    jobash_feature_exists "$ROOT" "$token" || return 2
    FEATURE_ID="$token"
  fi
  return 0
}

jobash_menu_choose() {
  local sel token rc
  while true; do
    echo
    jobash_print_features 1
    read -r -p "Enter numbers or ids (space/comma-separated), or 0 to go back: " sel
    if jobash_is_blank "$sel"; then
      jobash_input_reject
      continue
    fi
    if jobash_is_back "$sel"; then
      jobash_input_reset_strikes
      return 0
    fi
    FEATURE_SELECTION=()
    local bad=0
    jobash_split_selection "$sel"
    for token in "${JOBASH_TOKENS[@]}"; do
      if jobash_is_back "$token"; then
        jobash_input_reset_strikes
        return 0
      fi
      rc=0
      jobash_resolve_feature_token "$token" || rc=$?
      if [[ "$rc" -eq 2 ]]; then
        bad=1
        break
      fi
      if [[ "$rc" -eq 1 ]]; then
        jobash_input_reset_strikes
        return 0
      fi
      FEATURE_SELECTION+=("$FEATURE_ID")
    done
    if [[ "$bad" -eq 1 ]] || ((${#FEATURE_SELECTION[@]} == 0)); then
      jobash_input_reject
      continue
    fi
    jobash_input_reset_strikes
    jobash_do_install_selected
    return 0
  done
}

jobash_menu_example() {
  local sel rc
  while true; do
    echo
    jobash_print_features 0
    read -r -p "Enter number or id to demo, or 0 to go back: " sel
    if jobash_is_blank "$sel"; then
      jobash_input_reject
      continue
    fi
    rc=0
    jobash_resolve_feature_token "$sel" || rc=$?
    if [[ "$rc" -eq 1 ]]; then
      jobash_input_reset_strikes
      return 0
    fi
    if [[ "$rc" -eq 2 ]]; then
      jobash_input_reject
      continue
    fi
    echo
    jobash_ui_sep
    jobash_features_require_ids "$ROOT" "$FEATURE_ID"
    jobash_run_example "$ROOT" "$FEATURE_ID"
    echo
    jobash_ui_ok "example done — pick another feature or 0 to go back"
    jobash_input_reset_strikes
  done
}

jobash_interactive() {
  local choice
  jobash_input_reset_strikes
  while true; do
    echo
    jobash_ui_header
    echo
    jobash_ui_menu_item "1" "all" "— install every feature"
    jobash_ui_menu_item "2" "choose" "— pick features"
    jobash_ui_menu_item "3" "example" "— demo a feature (no install)"
    jobash_ui_menu_item "0" "quit" "— exit installer"
    echo
    jobash_ui_hint "Tip: 0 / back returns to the previous menu."
    read -r -p "Select [0-3]: " choice
    case "$choice" in
      1|all)
        jobash_input_reset_strikes
        jobash_do_install_all
        jobash_ui_ok "install complete"
        ;;
      2|choose)
        jobash_input_reset_strikes
        jobash_menu_choose
        ;;
      3|example)
        jobash_input_reset_strikes
        jobash_menu_example
        ;;
      0|q|quit|b|back)
        jobash_ui_ok "bye"
        exit 0
        ;;
      *)
        jobash_input_reject
        ;;
    esac
  done
}

if [[ -z "$MODE" ]]; then
  jobash_interactive
fi

case "$MODE" in
  all)
    jobash_do_install_all
    ;;
  features)
    if [[ -n "$FEATURES_CSV" ]]; then
      jobash_parse_csv "$FEATURES_CSV"
    fi
    jobash_do_install_selected
    ;;
  example)
    jobash_features_require_ids "$ROOT" "$EXAMPLE_ID"
    jobash_run_example "$ROOT" "$EXAMPLE_ID"
    ;;
  uninstall)
    jobash_uninstall "$ROOT" "$PREFIX" "$BASHRC"
    ;;
  *)
    jobash_die "internal: unknown mode $MODE"
    ;;
esac
