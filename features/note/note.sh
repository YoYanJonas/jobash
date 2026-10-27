#!/usr/bin/env bash
# note: append a dated line to a notes file
# Usage: note MESSAGE...
# Env: JOBASH_NOTES_FILE (default: ~/.jobash/notes.txt)
set -euo pipefail

usage() {
  echo "Usage: note MESSAGE..." >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
msg="$*"
[[ -n "${msg//[[:space:]]/}" ]] || usage

file="${JOBASH_NOTES_FILE:-$HOME/.jobash/notes.txt}"
mkdir -p "$(dirname "$file")"
ts="$(date '+%Y-%m-%d %H:%M:%S')"
printf '%s %s\n' "$ts" "$msg" >>"$file"
printf '%s\n' "$file"
