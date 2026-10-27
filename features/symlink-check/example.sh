#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s "$tmp/missing-target" "$tmp/broken"
ln -s "$tmp" "$tmp/ok-link"
echo "\$ symlink-check $tmp"
"$ROOT/symlink-check.sh" "$tmp"
