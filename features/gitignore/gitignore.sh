#!/usr/bin/env bash
# gitignore: append a pattern to the nearest .gitignore
# Usage: gitignore PATTERN
set -euo pipefail

usage() {
  echo "Usage: gitignore PATTERN" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
pattern="$1"
[[ -n "$pattern" ]] || usage

dir="$(pwd)"
gi=""
while true; do
  if [[ -f "$dir/.gitignore" ]]; then
    gi="$dir/.gitignore"
    break
  fi
  if [[ -d "$dir/.git" ]]; then
    gi="$dir/.gitignore"
    break
  fi
  parent="$(dirname -- "$dir")"
  [[ "$parent" != "$dir" ]] || break
  dir="$parent"
done

[[ -n "$gi" ]] || { echo "gitignore: no .gitignore or git repo above $(pwd)" >&2; exit 1; }

if [[ -f "$gi" ]] && grep -Fxq -- "$pattern" "$gi"; then
  echo "already present: $pattern ($gi)"
  exit 0
fi

[[ -f "$gi" ]] || : >"$gi"
printf '%s\n' "$pattern" >>"$gi"
echo "added: $pattern ($gi)"
