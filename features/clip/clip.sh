#!/usr/bin/env bash
# clip: copy stdin or a file to the clipboard
# Usage:
#   clip           -> read stdin
#   clip FILE      -> read file
# Prefers clip.exe (WSL), then wl-copy, then xclip, then xsel.
set -euo pipefail

usage() {
  echo "Usage: clip [FILE]" >&2
  exit 1
}

[[ $# -le 1 ]] || usage

input=""
if [[ $# -eq 1 ]]; then
  [[ -f "$1" ]] || { echo "clip: not a file: $1" >&2; exit 1; }
  input="$1"
fi

copy_cmd=()
if command -v clip.exe >/dev/null 2>&1; then
  copy_cmd=(clip.exe)
elif command -v wl-copy >/dev/null 2>&1; then
  copy_cmd=(wl-copy)
elif command -v xclip >/dev/null 2>&1; then
  copy_cmd=(xclip -selection clipboard)
elif command -v xsel >/dev/null 2>&1; then
  copy_cmd=(xsel --clipboard --input)
else
  echo "clip: no clipboard backend (clip.exe, wl-copy, xclip, or xsel)" >&2
  exit 1
fi

if [[ -n "$input" ]]; then
  "${copy_cmd[@]}" <"$input"
else
  if [[ -t 0 ]]; then
    echo "clip: no stdin data (pipe text or pass a FILE)" >&2
    exit 1
  fi
  "${copy_cmd[@]}"
fi

echo "copied"
