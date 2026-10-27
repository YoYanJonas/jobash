#!/usr/bin/env bash
# bak: copy a file or directory to a timestamped .bak sibling
# Usage: bak PATH
set -euo pipefail

usage() {
  echo "Usage: bak PATH" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
src="$1"

if [[ ! -e "$src" ]]; then
  echo "bak: not found: $src" >&2
  exit 1
fi

ts="$(date +%Y%m%d-%H%M%S)"
dest="${src}.${ts}.bak"

if [[ -e "$dest" ]]; then
  echo "bak: destination exists: $dest" >&2
  exit 1
fi

cp -a -- "$src" "$dest"
printf '%s\n' "$dest"
