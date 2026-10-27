#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACT="$ROOT/extract.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

mkdir payload
printf 'hi\n' >payload/hello.txt
tar -czf demo.tar.gz payload

echo "\$ extract demo.tar.gz"
"$EXTRACT" demo.tar.gz
ls payload/hello.txt
