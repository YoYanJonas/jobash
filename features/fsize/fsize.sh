#!/usr/bin/env bash
# fsize: human-readable size of a file or directory
# Usage: fsize PATH
set -euo pipefail

usage() {
  echo "Usage: fsize PATH" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
path="$1"
[[ -e "$path" ]] || { echo "fsize: not found: $path" >&2; exit 1; }

# Portable: prefer du -sh; normalize
if ! out="$(du -sh -- "$path" 2>/dev/null)"; then
  echo "fsize: failed to measure: $path" >&2
  exit 1
fi
size="$(awk '{print $1}' <<<"$out")"
printf '%s\t%s\n' "$size" "$path"
