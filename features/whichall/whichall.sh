#!/usr/bin/env bash
# whichall: print every executable match for a command on PATH
# Usage: whichall NAME
set -euo pipefail

usage() {
  echo "Usage: whichall NAME" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
name="$1"
[[ -n "$name" ]] || usage

found=0
IFS=':' read -ra dirs <<<"${PATH:-}"
for dir in "${dirs[@]}"; do
  [[ -n "$dir" ]] || continue
  cand="$dir/$name"
  if [[ -f "$cand" && -x "$cand" ]]; then
    printf '%s\n' "$cand"
    found=1
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "whichall: $name not found in PATH" >&2
  exit 1
fi
