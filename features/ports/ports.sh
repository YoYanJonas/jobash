#!/usr/bin/env bash
# ports: list listening TCP sockets (optional port filter)
# Usage:
#   ports           -> all listening TCP local ports + pid/process when available
#   ports PORT      -> only that port
set -euo pipefail

usage() {
  echo "Usage: ports [PORT]" >&2
  exit 1
}

filter=""
if [[ $# -eq 1 ]]; then
  filter="$1"
  [[ "$filter" =~ ^[0-9]+$ ]] || usage
elif [[ $# -gt 1 ]]; then
  usage
fi

if ! command -v ss >/dev/null 2>&1; then
  echo "ports: ss not found (install iproute2)" >&2
  exit 1
fi

# Prefer pid/process column when permitted; fall back without -p.
ss_out=""
if ss_out="$(ss -H -tlnp 2>/dev/null)"; then
  :
else
  ss_out="$(ss -H -tln 2>/dev/null)" || {
    echo "ports: failed to query listening sockets" >&2
    exit 1
  }
fi

found=0
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -n "$line" ]] || continue
  # Local address is field 4: 127.0.0.1:39067 or *:80 or [::]:443
  local_addr="$(awk '{print $4}' <<<"$line")"
  port="${local_addr##*:}"
  # Strip IPv6 brackets residue if any odd form
  port="${port%]}"
  [[ "$port" =~ ^[0-9]+$ ]] || continue
  if [[ -n "$filter" && "$port" != "$filter" ]]; then
    continue
  fi

  proc=""
  if [[ "$line" =~ users:\(\(\"([^\"]+)\",pid=([0-9]+) ]]; then
    proc="${BASH_REMATCH[1]} pid=${BASH_REMATCH[2]}"
  elif [[ "$line" =~ pid=([0-9]+) ]]; then
    proc="pid=${BASH_REMATCH[1]}"
  fi

  if [[ -n "$proc" ]]; then
    printf '%s\t%s\n' "$port" "$proc"
  else
    printf '%s\n' "$port"
  fi
  found=1
done <<<"$ss_out"

if [[ "$found" -eq 0 ]]; then
  if [[ -n "$filter" ]]; then
    echo "ports: nothing listening on port $filter" >&2
  else
    echo "ports: no listening TCP ports" >&2
  fi
  exit 1
fi
