#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$ urldec 'a%20b%3Dc'"
"$ROOT/urldec.sh" 'a%20b%3Dc'
