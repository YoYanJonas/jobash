#!/usr/bin/env bash
# envgrep: grep environment variables by name/value
# Usage: envgrep PATTERN
set -euo pipefail

usage() {
  echo "Usage: envgrep PATTERN" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
pat="$1"
[[ -n "$pat" ]] || usage

found=0
while IFS= read -r line; do
  if [[ "$line" == *"$pat"* ]]; then
    printf '%s\n' "$line"
    found=1
  fi
done < <(env | sort)

if [[ "$found" -eq 0 ]]; then
  echo "envgrep: no matches for: $pat" >&2
  exit 1
fi
