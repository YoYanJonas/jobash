#!/usr/bin/env bash
# urlenc: URL-encode a string
# Usage: urlenc STRING
set -euo pipefail

usage() {
  echo "Usage: urlenc STRING" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
if ! command -v python3 >/dev/null 2>&1; then
  echo "urlenc: python3 not found" >&2
  exit 1
fi
python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
