#!/usr/bin/env bash
# jsonpp: pretty-print JSON from a file or stdin
# Usage: jsonpp [FILE]
set -euo pipefail

usage() {
  echo "Usage: jsonpp [FILE]" >&2
  exit 1
}

[[ $# -le 1 ]] || usage

if command -v python3 >/dev/null 2>&1; then
  py=python3
elif command -v python >/dev/null 2>&1; then
  py=python
else
  echo "jsonpp: python3 not found" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  [[ -f "$1" ]] || { echo "jsonpp: not a file: $1" >&2; exit 1; }
  "$py" -c 'import json,sys; json.dump(json.load(open(sys.argv[1])), sys.stdout, indent=2); print()' "$1"
else
  if [[ -t 0 ]]; then
    echo "jsonpp: no stdin data (pipe JSON or pass a FILE)" >&2
    exit 1
  fi
  "$py" -c 'import json,sys; json.dump(json.load(sys.stdin), sys.stdout, indent=2); print()'
fi
