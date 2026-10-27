#!/usr/bin/env bash
# Shared helpers for Jobash installer and libs.
# shellcheck shell=bash

jobash_repo_root() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  printf '%s\n' "$here"
}

jobash_die() {
  printf 'jobash: %s\n' "$*" >&2
  exit 1
}

jobash_info() {
  printf 'jobash: %s\n' "$*"
}

jobash_require_file() {
  [[ -f "$1" ]] || jobash_die "missing file: $1"
}

jobash_require_dir() {
  [[ -d "$1" ]] || jobash_die "missing directory: $1"
}

# Split a space/comma-separated selection into JOBASH_TOKENS.
# Uses an explicit IFS so a leaked caller IFS cannot glue tokens together.
jobash_split_selection() {
  local raw="${1:-}"
  local normalized
  normalized="${raw//,/ }"
  JOBASH_TOKENS=()
  local IFS=$' \t\n'
  # shellcheck disable=SC2206
  JOBASH_TOKENS=($normalized)
}
