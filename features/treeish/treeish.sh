#!/usr/bin/env bash
# treeish: simple depth-limited directory tree
# Usage: treeish [DIR] [DEPTH]
set -euo pipefail

usage() {
  echo "Usage: treeish [DIR] [DEPTH]" >&2
  exit 1
}

dir="${1:-.}"
depth="${2:-2}"
[[ $# -le 2 ]] || usage
[[ -d "$dir" ]] || { echo "treeish: not a directory: $dir" >&2; exit 1; }
[[ "$depth" =~ ^[0-9]+$ ]] || usage

_treeish_walk() {
  local path="$1" level="$2" prefix="$3"
  (( level < depth )) || return 0

  local -a kids=()
  local entry
  shopt -s nullglob
  for entry in "$path"/*; do
    kids+=("$entry")
  done
  shopt -u nullglob

  local i child cname next_prefix
  for i in "${!kids[@]}"; do
    child="${kids[$i]}"
    cname="$(basename -- "$child")"
    if (( i == ${#kids[@]} - 1 )); then
      next_prefix="${prefix}    "
      printf '%s└── %s\n' "$prefix" "$cname"
    else
      next_prefix="${prefix}│   "
      printf '%s├── %s\n' "$prefix" "$cname"
    fi
    if [[ -d "$child" ]]; then
      _treeish_walk "$child" $((level + 1)) "$next_prefix"
    fi
  done
}

printf '%s\n' "$(basename -- "$dir")"
_treeish_walk "$dir" 0 ""
