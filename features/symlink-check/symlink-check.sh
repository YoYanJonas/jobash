#!/usr/bin/env bash
# symlink-check: report broken symlinks under a path
# Usage: symlink-check DIR
set -euo pipefail

usage() {
  echo "Usage: symlink-check DIR" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
dir="$1"
[[ -d "$dir" ]] || { echo "symlink-check: not a directory: $dir" >&2; exit 1; }

found=0
while IFS= read -r -d '' link; do
  if [[ ! -e "$link" ]]; then
    printf '%s\n' "$link"
    found=1
  fi
done < <(find "$dir" -type l -print0)

if [[ "$found" -eq 0 ]]; then
  echo "symlink-check: no broken symlinks under $dir" >&2
  exit 1
fi
