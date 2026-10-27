#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Offline demo via fake curl on PATH
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/curl" <<'EOF'
#!/bin/sh
echo "Tehran: ☀️ +22°C"
EOF
chmod +x "$tmp/curl"
echo "\$ weather Tehran"
PATH="$tmp:$PATH" "$ROOT/weather.sh" Tehran
