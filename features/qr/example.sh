#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/qrencode" <<'EOF'
#!/bin/sh
echo "QR[$1]"
EOF
chmod +x "$tmp/qrencode"
echo "\$ qr 'https://example.com'"
PATH="$tmp:$PATH" "$ROOT/qr.sh" 'https://example.com'
