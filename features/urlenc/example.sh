#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$ urlenc 'a b=c'"
"$ROOT/urlenc.sh" 'a b=c'
