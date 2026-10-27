#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/a/b" "$tmp/c"
touch "$tmp/a/x" "$tmp/a/b/y" "$tmp/c/z"
echo "\$ treeish $tmp 2"
"$ROOT/treeish.sh" "$tmp" 2
