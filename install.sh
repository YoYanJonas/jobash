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

jobash_menu() {
  local choice i sel idx meta desc
  echo "Jobash installer"
  echo "  1) all      — install every feature"
  echo "  2) choose   — pick features"
  echo "  3) example  — demo a feature (no install)"
  echo
  read -r -p "Select [1-3]: " choice
  case "$choice" in
    1|all)
      MODE="all"
      ;;
    2|choose)
      MODE="features"
      echo "Available features:"
      i=1
      for id in "${JOBASH_FEATURE_IDS[@]}"; do
        meta="$(jobash_feature_meta_path "$ROOT" "$id")"
        desc="$(jobash_feature_meta_get "$meta" description 2>/dev/null || true)"
        printf '  %d) %s — %s\n' "$i" "$id" "${desc:-}"
        i=$((i + 1))
      done
      read -r -p "Enter numbers or ids (space/comma-separated): " sel
      FEATURE_SELECTION=()
      # shellcheck disable=SC2086
      for token in ${sel//,/ }; do
        if [[ "$token" =~ ^[0-9]+$ ]]; then
          idx=$((token - 1))
          ((idx >= 0 && idx < ${#JOBASH_FEATURE_IDS[@]})) \
            || jobash_die "invalid selection: $token"
          FEATURE_SELECTION+=("${JOBASH_FEATURE_IDS[$idx]}")
        else
          FEATURE_SELECTION+=("$token")
        fi
      done
      ((${#FEATURE_SELECTION[@]} > 0)) || jobash_die "no features selected"
      ;;
    3|example)
      MODE="example"
      echo "Available features:"
      i=1
      for id in "${JOBASH_FEATURE_IDS[@]}"; do
        printf '  %d) %s\n' "$i" "$id"
        i=$((i + 1))
      done
      read -r -p "Enter number or id: " sel
      if [[ "$sel" =~ ^[0-9]+$ ]]; then
        idx=$((sel - 1))
        ((idx >= 0 && idx < ${#JOBASH_FEATURE_IDS[@]})) \
          || jobash_die "invalid selection: $sel"
        EXAMPLE_ID="${JOBASH_FEATURE_IDS[$idx]}"
      else
        EXAMPLE_ID="$sel"
      fi
      ;;
    *)
      jobash_die "invalid menu choice: $choice"
      ;;
  esac
}

if [[ -z "$MODE" ]]; then
  jobash_menu
fi

case "$MODE" in
  all)
    jobash_features_require_ids "$ROOT" "${JOBASH_FEATURE_IDS[@]}"
    jobash_install_features "$ROOT" "$PREFIX" "$BASHRC" "${JOBASH_FEATURE_IDS[@]}"
    ;;
  features)
    if [[ -n "$FEATURES_CSV" ]]; then
      jobash_parse_csv "$FEATURES_CSV"
    fi
    jobash_features_require_ids "$ROOT" "${FEATURE_SELECTION[@]}"
    jobash_install_features "$ROOT" "$PREFIX" "$BASHRC" "${FEATURE_SELECTION[@]}"
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
