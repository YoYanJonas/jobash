#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
dd if=/dev/zero of="$tmp/blob" bs=1024 count=4 status=none 2>/dev/null || dd if=/dev/zero of="$tmp/blob" bs=1024 count=4 2>/dev/null
echo "\$ fsize $tmp/blob"
"$ROOT/fsize.sh" "$tmp/blob"
