#!/usr/bin/env bash
# biggest: list largest files under a path
# Usage: biggest DIR [N]
set -euo pipefail

usage() {
  echo "Usage: biggest DIR [N]" >&2
  exit 1
}

[[ $# -ge 1 && $# -le 2 ]] || usage
dir="$1"
n="${2:-10}"
[[ -d "$dir" ]] || { echo "biggest: not a directory: $dir" >&2; exit 1; }
[[ "$n" =~ ^[1-9][0-9]*$ ]] || usage

if find --version >/dev/null 2>&1; then
  find "$dir" -type f -printf '%s\t%p\n' | sort -nr | head -n "$n"
else
  find "$dir" -type f -print0 | while IFS= read -r -d '' f; do
    sz="$(wc -c <"$f" | tr -d ' ')"
    printf '%s\t%s\n' "$sz" "$f"
  done | sort -nr | head -n "$n"
fi
