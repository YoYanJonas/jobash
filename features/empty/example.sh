#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/empty-dir"
: >"$tmp/empty-file"
printf 'x\n' >"$tmp/full"
echo "\$ empty $tmp"
"$ROOT/empty.sh" "$tmp"
