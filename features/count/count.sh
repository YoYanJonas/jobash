#!/usr/bin/env bash
# count: report file and/or directory counts in a path
# Usage:
#   count DIR            -> "N files, M dirs"
#   count -f DIR         -> files only (number)
#   count -d DIR         -> dirs only (number)

set -euo pipefail

usage() {
  echo "Usage: count [-f|-d] DIR" >&2
  echo "  (no flag)  NUMBEROFFILE files, NUMBEROFDIRS dirs" >&2
  echo "  -f         count files only" >&2
  echo "  -d         count directories only" >&2
  exit 1
}

mode="all"
dir=""

while getopts ":fdh" opt; do
  case "$opt" in
    f) mode="files" ;;
    d) mode="dirs" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

dir="${1:-}"
[[ -n "$dir" ]] || usage

if [[ ! -d "$dir" ]]; then
  echo "count: not a directory: $dir" >&2
  exit 1
fi

# Non-recursive: only immediate children (excluding . and ..)
files=$(find "$dir" -mindepth 1 -maxdepth 1 -type f | wc -l)
dirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)

# trim whitespace from wc
files=${files//[[:space:]]/}
dirs=${dirs//[[:space:]]/}

case "$mode" in
  files) echo "$files" ;;
  dirs)  echo "$dirs" ;;
  all)   echo "${files} files, ${dirs} dirs" ;;
esac
