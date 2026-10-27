#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/clip.exe" <<'EOF'
#!/bin/sh
cat >"${CLIP_SINK:-/dev/null}"
EOF
chmod +x "$tmp/clip.exe"
export CLIP_SINK="$tmp/out.txt"
echo "hello clip" | PATH="$tmp:$PATH" "$ROOT/clip.sh"
cat "$CLIP_SINK"
