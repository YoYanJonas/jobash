#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$ timer sleep 0.2"
"$ROOT/timer.sh" sleep 0.2
