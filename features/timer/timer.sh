#!/usr/bin/env bash
# timer: time a command and print elapsed seconds
# Usage: timer COMMAND [ARGS...]
set -euo pipefail

usage() {
  echo "Usage: timer COMMAND [ARGS...]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage

start="$(date +%s.%N)"
set +e
"$@"
status=$?
set -e
end="$(date +%s.%N)"
elapsed="$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }')"
echo "timer: ${elapsed}s (exit $status)" >&2
exit "$status"
