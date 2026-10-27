#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAK="$ROOT/bak.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf 'hello\n' >"$tmp/note.txt"

echo "\$ bak $tmp/note.txt"
out="$("$BAK" "$tmp/note.txt")"
echo "created: $out"
cat "$out"
