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
  --uninstall           Remove installed bins + JOBASH bashrc block
  -h, --help            Show this help
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
  echo "Available features:"
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    if [[ "$with_desc" == "1" ]]; then
      meta="$(jobash_feature_meta_path "$ROOT" "$id")"
      desc="$(jobash_feature_meta_get "$meta" description 2>/dev/null || true)"
      printf '  %d) %s — %s\n' "$i" "$id" "${desc:-}"
    else
      printf '  %d) %s\n' "$i" "$id"
    fi
    i=$((i + 1))
  done
  echo "  0) back"
}

# Resolve number or id → FEATURE_ID. Returns 1 if back; dies on invalid.
jobash_resolve_feature_token() {
  local token="$1" idx
  FEATURE_ID=""
  if jobash_is_back "$token"; then
    return 1
  fi
  if [[ "$token" =~ ^[0-9]+$ ]]; then
    idx=$((token - 1))
    ((idx >= 0 && idx < ${#JOBASH_FEATURE_IDS[@]})) \
      || jobash_die "invalid selection: $token"
    FEATURE_ID="${JOBASH_FEATURE_IDS[$idx]}"
  else
    jobash_feature_exists "$ROOT" "$token" || jobash_die "unknown feature: $token"
    FEATURE_ID="$token"
  fi
  return 0
}

jobash_menu_choose() {
  local sel token idx
  while true; do
    echo
    jobash_print_features 1
    read -r -p "Enter numbers or ids (space/comma-separated), or 0 to go back: " sel
    if jobash_is_blank "$sel"; then
      jobash_info "no features selected"
      continue
    fi
    if jobash_is_back "$sel"; then
      return 0
    fi
    FEATURE_SELECTION=()
    # shellcheck disable=SC2086
    for token in ${sel//,/ }; do
      if jobash_is_back "$token"; then
        return 0
      fi
      if ! jobash_resolve_feature_token "$token"; then
        return 0
      fi
      FEATURE_SELECTION+=("$FEATURE_ID")
    done
    if ((${#FEATURE_SELECTION[@]} == 0)); then
      jobash_info "no features selected"
      continue
    fi
    jobash_do_install_selected
    return 0
  done
}

jobash_menu_example() {
  local sel
  while true; do
    echo
    jobash_print_features 0
    read -r -p "Enter number or id to demo, or 0 to go back: " sel
    if jobash_is_blank "$sel"; then
      continue
    fi
    if ! jobash_resolve_feature_token "$sel"; then
      return 0
    fi
    echo
    jobash_features_require_ids "$ROOT" "$FEATURE_ID"
    jobash_run_example "$ROOT" "$FEATURE_ID"
    echo
    jobash_info "example done — pick another feature or 0 to go back"
  done
}

jobash_interactive() {
  local choice
  while true; do
    echo
    echo "Jobash installer"
    echo "  1) all      — install every feature"
    echo "  2) choose   — pick features"
    echo "  3) example  — demo a feature (no install)"
    echo "  0) quit"
    echo
    read -r -p "Select [0-3]: " choice
    case "$choice" in
      1|all)
        jobash_do_install_all
        ;;
      2|choose)
        jobash_menu_choose
        ;;
      3|example)
        jobash_menu_example
        ;;
      0|q|quit|b|back)
        jobash_info "bye"
        exit 0
        ;;
      *)
        jobash_info "invalid menu choice: $choice"
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
