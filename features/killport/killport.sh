#!/usr/bin/env bash
# killport: kill process(es) listening on a TCP port
# Usage: killport PORT
set -euo pipefail

usage() {
  echo "Usage: killport PORT" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
port="$1"
[[ "$port" =~ ^[0-9]+$ ]] || usage

if ! command -v ss >/dev/null 2>&1; then
  echo "killport: ss not found (install iproute2)" >&2
  exit 1
fi

ss_out="$(ss -H -tlnp 2>/dev/null || ss -H -tln 2>/dev/null || true)"
pids=()
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -n "$line" ]] || continue
  local_addr="$(awk '{print $4}' <<<"$line")"
  p="${local_addr##*:}"
  p="${p%]}"
  [[ "$p" == "$port" ]] || continue
  while [[ "$line" =~ pid=([0-9]+) ]]; do
    pids+=("${BASH_REMATCH[1]}")
    line="${line#*pid=${BASH_REMATCH[1]}}"
  done
done <<<"$ss_out"

if ((${#pids[@]} == 0)); then
  echo "killport: nothing listening on port $port" >&2
  exit 1
fi

# Unique PIDs
mapfile -t pids < <(printf '%s\n' "${pids[@]}" | sort -u)

killed=0
for pid in "${pids[@]}"; do
  if kill "$pid" 2>/dev/null; then
    echo "killed pid $pid on port $port"
    killed=1
  fi
done

if [[ "$killed" -eq 0 ]]; then
  echo "killport: found pid(s) but could not signal them (permission?)" >&2
  exit 1
fi
