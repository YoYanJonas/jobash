#!/usr/bin/env bash
# trash: move paths into a trash directory
# Usage: trash PATH [PATH...]
# Env: JOBASH_TRASH_DIR (default: ~/.local/share/Trash/files)
set -euo pipefail

usage() {
  echo "Usage: trash PATH [PATH...]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage

trash_dir="${JOBASH_TRASH_DIR:-$HOME/.local/share/Trash/files}"
mkdir -p "$trash_dir"

for path in "$@"; do
  [[ -e "$path" ]] || { echo "trash: not found: $path" >&2; exit 1; }
  base="$(basename -- "$path")"
  dest="$trash_dir/$base"
  if [[ -e "$dest" ]]; then
    dest="$trash_dir/${base}.$(date +%Y%m%d-%H%M%S)"
  fi
  mv -- "$path" "$dest"
  printf '%s\n' "$dest"
done
