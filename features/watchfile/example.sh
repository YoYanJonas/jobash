#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
printf 'v1\n' >"$tmp"
JOBASH_WATCH_ONCE=1 JOBASH_WATCH_INTERVAL=0.1 \
  "$ROOT/watchfile.sh" "$tmp" cat "$tmp" &
pid=$!
sleep 0.2
printf 'v2\n' >"$tmp"
wait "$pid"
