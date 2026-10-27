#!/usr/bin/env bash
# Demo for the count feature (no install, no bashrc changes).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COUNT="$ROOT/count.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/a" "$tmp/b"
touch "$tmp/one.txt" "$tmp/two.txt" "$tmp/three.txt"

echo "Demo directory: $tmp"
echo "  contents: 3 files, 2 dirs"
echo
echo "\$ count $tmp"
"$COUNT" "$tmp"
echo
echo "\$ count -f $tmp"
"$COUNT" -f "$tmp"
echo
echo "\$ count -d $tmp"
"$COUNT" -d "$tmp"
