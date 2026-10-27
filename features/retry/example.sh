#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cat >"$tmp" <<'EOF'
#!/bin/sh
n=$(cat "$COUNTFILE" 2>/dev/null || echo 0)
n=$((n+1)); echo "$n" >"$COUNTFILE"
[ "$n" -ge 2 ]
EOF
chmod +x "$tmp"
export COUNTFILE
COUNTFILE="$(mktemp)"
echo "\$ retry 3 0 $tmp"
"$ROOT/retry.sh" 3 0 "$tmp"
echo "attempts: $(cat "$COUNTFILE")"
rm -f "$COUNTFILE"
