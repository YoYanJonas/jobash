#!/usr/bin/env bash
# dupes: find duplicate files by checksum (sha256)
# Usage: dupes DIR
set -euo pipefail

usage() {
  echo "Usage: dupes DIR" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
root="$1"
[[ -d "$root" ]] || { echo "dupes: not a directory: $root" >&2; exit 1; }

if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
  echo "dupes: need sha256sum or shasum" >&2
  exit 1
fi

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -- "$1" | awk '{print $1}'
  else
    shasum -a 256 -- "$1" | awk '{print $1}'
  fi
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Collect hash -> paths
while IFS= read -r -d '' f; do
  [[ -f "$f" && ! -L "$f" ]] || continue
  h="$(hash_file "$f")"
  printf '%s\t%s\n' "$h" "$f" >>"$tmp"
done < <(find "$root" -type f -print0)

found=0
# Group by hash; print groups with >1 file
while IFS= read -r h; do
  mapfile -t files < <(awk -F '\t' -v h="$h" '$1==h {print $2}' "$tmp")
  if ((${#files[@]} > 1)); then
    found=1
    printf 'hash %s\n' "$h"
    for f in "${files[@]}"; do
      printf '  %s\n' "$f"
    done
  fi
done < <(cut -f1 "$tmp" | sort -u)

if [[ "$found" -eq 0 ]]; then
  echo "dupes: no duplicates under $root" >&2
  exit 1
fi
