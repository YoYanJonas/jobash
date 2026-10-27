#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"; kill $pid 2>/dev/null || true' EXIT
cd "$tmp"
printf 'ok\n' >index.html
"$ROOT/serve.sh" 8765 &
pid=$!
sleep 0.4
curl -fsS "http://127.0.0.1:8765/index.html"
echo
