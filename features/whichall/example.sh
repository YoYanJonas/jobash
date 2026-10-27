#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHICHALL="$ROOT/whichall.sh"

echo "\$ whichall bash"
"$WHICHALL" bash
