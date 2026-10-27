#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf 'same\n' >"$tmp/a.txt"
printf 'same\n' >"$tmp/b.txt"
printf 'other\n' >"$tmp/c.txt"
echo "\$ dupes $tmp"
"$ROOT/dupes.sh" "$tmp" || true
