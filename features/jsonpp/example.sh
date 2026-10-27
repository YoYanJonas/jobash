#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
printf '{"a":1,"b":[2,3]}\n' >"$tmp"
echo "\$ jsonpp $tmp"
"$ROOT/jsonpp.sh" "$tmp"
