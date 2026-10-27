#!/usr/bin/env bash
# human: convert bytes or seconds to human-readable form
# Usage:
#   human BYTES           -> bytes (auto)
#   human -b BYTES
#   human -s SECONDS
set -euo pipefail

usage() {
  echo "Usage: human [-b|-s] NUMBER" >&2
  exit 1
}

mode="bytes"
num=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b) mode="bytes"; shift ;;
    -s) mode="seconds"; shift ;;
    -h|--help) usage ;;
    *)
      [[ -z "$num" ]] || usage
      num="$1"
      shift
      ;;
  esac
done
[[ -n "$num" ]] || usage
[[ "$num" =~ ^[0-9]+([.][0-9]+)?$ ]] || usage

if [[ "$mode" == "seconds" ]]; then
  awk -v n="$num" 'BEGIN {
    if (n < 60) { printf "%.2fs\n", n; exit }
    m = int(n / 60); s = n - m * 60
    if (m < 60) { printf "%dm %.0fs\n", m, s; exit }
    h = int(m / 60); m = m - h * 60
    printf "%dh %dm\n", h, m
  }'
  exit 0
fi

awk -v n="$num" 'BEGIN {
  split("B KB MB GB TB", u, " ")
  i = 1
  while (n >= 1024 && i < 5) { n /= 1024; i++ }
  if (i == 1) printf "%dB\n", n
  else printf "%.1f%s\n", n, u[i]
}'
