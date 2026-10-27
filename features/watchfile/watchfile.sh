#!/usr/bin/env bash
# watchfile: run a command when a file's mtime changes
# Usage: watchfile FILE COMMAND [ARGS...]
# Env: JOBASH_WATCH_INTERVAL seconds (default 0.5), JOBASH_WATCH_ONCE=1 for tests
set -euo pipefail

usage() {
  echo "Usage: watchfile FILE COMMAND [ARGS...]" >&2
  exit 1
}

[[ $# -ge 2 ]] || usage
file="$1"
shift
[[ -e "$file" ]] || { echo "watchfile: not found: $file" >&2; exit 1; }

interval="${JOBASH_WATCH_INTERVAL:-0.5}"
once="${JOBASH_WATCH_ONCE:-0}"

stamp_of() {
  # Include size so same-second rewrites are still detected.
  if stat -c '%Y %s' -- "$1" >/dev/null 2>&1; then
    stat -c '%Y %s' -- "$1"
  else
    stat -f '%m %z' -- "$1"
  fi
}

last="$(stamp_of "$file")"
echo "watchfile: watching $file" >&2

while true; do
  sleep "$interval"
  [[ -e "$file" ]] || { echo "watchfile: file disappeared: $file" >&2; exit 1; }
  now="$(stamp_of "$file")"
  if [[ "$now" != "$last" ]]; then
    last="$now"
    echo "watchfile: change detected" >&2
    "$@"
    if [[ "$once" == "1" ]]; then
      exit 0
    fi
  fi
done

