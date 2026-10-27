#!/usr/bin/env bash
# urldec: URL-decode a string
# Usage: urldec STRING
set -euo pipefail

usage() {
  echo "Usage: urldec STRING" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
if ! command -v python3 >/dev/null 2>&1; then
  echo "urldec: python3 not found" >&2
  exit 1
fi
python3 -c 'import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$1"
