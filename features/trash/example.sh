#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export JOBASH_TRASH_DIR="$tmp/trash"
printf 'x\n' >"$tmp/old.log"
echo "\$ trash $tmp/old.log"
"$ROOT/trash.sh" "$tmp/old.log"
ls "$JOBASH_TRASH_DIR"
