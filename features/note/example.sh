#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export JOBASH_NOTES_FILE="$tmp/notes.txt"
echo "\$ note shipped count feature"
"$ROOT/note.sh" "shipped count feature"
cat "$JOBASH_NOTES_FILE"
