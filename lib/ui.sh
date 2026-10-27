#!/usr/bin/env bash
# Terminal UI helpers for the interactive installer.
# shellcheck shell=bash

jobash_ui_init() {
  JOBASH_UI_COLOR=0
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    JOBASH_UI_COLOR=1
    JOBASH_UI_RESET=$'\033[0m'
    JOBASH_UI_BOLD=$'\033[1m'
    JOBASH_UI_DIM=$'\033[2m'
    JOBASH_UI_CYAN=$'\033[36m'
    JOBASH_UI_GREEN=$'\033[32m'
    JOBASH_UI_YELLOW=$'\033[33m'
    JOBASH_UI_RED=$'\033[31m'
  else
    JOBASH_UI_RESET='' JOBASH_UI_BOLD='' JOBASH_UI_DIM=''
    JOBASH_UI_CYAN='' JOBASH_UI_GREEN='' JOBASH_UI_YELLOW='' JOBASH_UI_RED=''
  fi
}

JOBASH_UI_LINE='────────────────────────────────────────'

# Optional arg: version string shown next to the brand.
jobash_ui_header() {
  local ver="${1:-}"
  printf '%s\n' "${JOBASH_UI_DIM}${JOBASH_UI_LINE}${JOBASH_UI_RESET}"
  if [[ -n "$ver" ]]; then
    printf '%s%s%s %s%s%s\n' \
      "${JOBASH_UI_BOLD}${JOBASH_UI_CYAN}" "  JOBASH" "${JOBASH_UI_RESET}" \
      "${JOBASH_UI_DIM}" "$ver" "${JOBASH_UI_RESET}"
  else
    printf '%s%s%s\n' "${JOBASH_UI_BOLD}${JOBASH_UI_CYAN}" "  JOBASH" "${JOBASH_UI_RESET}"
  fi
  printf '%s%s%s\n' "${JOBASH_UI_DIM}" "  personal bash helpers" "${JOBASH_UI_RESET}"
  printf '%s\n' "${JOBASH_UI_DIM}${JOBASH_UI_LINE}${JOBASH_UI_RESET}"
}

jobash_ui_sep() {
  printf '%s\n' "${JOBASH_UI_DIM}${JOBASH_UI_LINE}${JOBASH_UI_RESET}"
}

jobash_ui_menu_item() {
  local num="$1" label="$2" hint="${3:-}"
  if [[ -n "$hint" ]]; then
    printf '  %s%2s)%s %-8s %s%s%s\n' \
      "${JOBASH_UI_BOLD}" "$num" "${JOBASH_UI_RESET}" "$label" \
      "${JOBASH_UI_DIM}" "$hint" "${JOBASH_UI_RESET}"
  else
    printf '  %s%2s)%s %s\n' "${JOBASH_UI_BOLD}" "$num" "${JOBASH_UI_RESET}" "$label"
  fi
}

jobash_ui_ok() {
  printf '%s[+]%s %s\n' "${JOBASH_UI_GREEN}" "${JOBASH_UI_RESET}" "$*"
}

jobash_ui_warn() {
  printf '%s[-]%s %s\n' "${JOBASH_UI_YELLOW}" "${JOBASH_UI_RESET}" "$*"
}

jobash_ui_err() {
  printf '%s[!]%s %s\n' "${JOBASH_UI_RED}" "${JOBASH_UI_RESET}" "$*" >&2
}

jobash_ui_hint() {
  printf '%s%s%s\n' "${JOBASH_UI_DIM}" "$*" "${JOBASH_UI_RESET}"
}

# Interactive input strikes: warn up to 3 times, then exit.
JOBASH_BAD_INPUTS="${JOBASH_BAD_INPUTS:-0}"

jobash_input_reset_strikes() {
  JOBASH_BAD_INPUTS=0
}

jobash_input_reject() {
  JOBASH_BAD_INPUTS=$((JOBASH_BAD_INPUTS + 1))
  if ((JOBASH_BAD_INPUTS > 3)); then
    printf '%s\n' "bye, you cant use this app. you cant input properly. so not for you. sorry :))"
    exit 1
  fi
  jobash_ui_err "you need to check options again. bad request!"
}
