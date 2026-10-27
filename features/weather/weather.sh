#!/usr/bin/env bash
# weather: short weather line for a place (wttr.in)
# Usage: weather PLACE
set -euo pipefail

usage() {
  echo "Usage: weather PLACE" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
place="$*"
place="${place#"${place%%[![:space:]]*}"}"
place="${place%"${place##*[![:space:]]}"}"
[[ -n "$place" ]] || usage

if ! command -v curl >/dev/null 2>&1; then
  echo "weather: curl not found" >&2
  exit 1
fi

# URL-encode spaces as + for wttr.in path
enc="${place// /+}"
url="https://wttr.in/${enc}?format=3"

if ! out="$(curl -fsS --max-time 10 "$url")"; then
  echo "weather: request failed for: $place" >&2
  exit 1
fi

printf '%s\n' "$out"
