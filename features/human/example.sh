#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$ human 1536000"
"$ROOT/human.sh" 1536000
echo "\$ human -s 3661"
"$ROOT/human.sh" -s 3661
