#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf 'a\n' >"$tmp/small"
dd if=/dev/zero of="$tmp/big" bs=1024 count=8 status=none 2>/dev/null || dd if=/dev/zero of="$tmp/big" bs=1024 count=8 2>/dev/null
echo "\$ biggest $tmp 2"
"$ROOT/biggest.sh" "$tmp" 2
