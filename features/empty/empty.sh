#!/usr/bin/env bash
# empty: list empty files and directories under a path
# Usage: empty DIR
set -euo pipefail

usage() {
  echo "Usage: empty DIR" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
dir="$1"
[[ -d "$dir" ]] || { echo "empty: not a directory: $dir" >&2; exit 1; }

found=0
while IFS= read -r -d '' p; do
  printf '%s\n' "$p"
  found=1
done < <(find "$dir" \( -type f -empty -o -type d -empty \) -print0)

if [[ "$found" -eq 0 ]]; then
  echo "empty: no empty files or directories under $dir" >&2
  exit 1
fi
