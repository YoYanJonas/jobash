#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export JOBASH_DEMO=1
echo "\$ envgrep JOBASH"
"$ROOT/envgrep.sh" JOBASH
