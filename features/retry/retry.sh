#!/usr/bin/env bash
# retry: run a command up to N times with delay between attempts
# Usage: retry TIMES DELAY COMMAND [ARGS...]
set -euo pipefail

usage() {
  echo "Usage: retry TIMES DELAY COMMAND [ARGS...]" >&2
  exit 1
}

[[ $# -ge 3 ]] || usage
times="$1"
delay="$2"
shift 2
[[ "$times" =~ ^[1-9][0-9]*$ ]] || usage
[[ "$delay" =~ ^[0-9]+([.][0-9]+)?$ ]] || usage

n=1
while true; do
  set +e
  "$@"
  status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
    exit 0
  fi
  if (( n >= times )); then
    echo "retry: failed after $times attempts (last exit $status)" >&2
    exit "$status"
  fi
  echo "retry: attempt $n failed; sleeping ${delay}s" >&2
  sleep "$delay"
  n=$((n + 1))
done
