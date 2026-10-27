#!/usr/bin/env bash
# serve: HTTP-serve the current directory
# Usage: serve [PORT]
set -euo pipefail

usage() {
  echo "Usage: serve [PORT]" >&2
  exit 1
}

port="${1:-8000}"
[[ $# -le 1 ]] || usage
[[ "$port" =~ ^[0-9]+$ ]] || usage

if ! command -v python3 >/dev/null 2>&1; then
  echo "serve: python3 not found" >&2
  exit 1
fi

echo "serve: http://127.0.0.1:${port}/ (ctrl-c to stop)" >&2
exec python3 -m http.server "$port" --bind 127.0.0.1
