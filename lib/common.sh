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
