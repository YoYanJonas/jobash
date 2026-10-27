#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
cd "$tmp"
echo "\$ gitignore node_modules/"
"$ROOT/gitignore.sh" "node_modules/"
cat .gitignore
