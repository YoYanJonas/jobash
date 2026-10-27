#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shell.sh
source "$ROOT/shell.sh"

echo "\$ mktempdir demo"
here="$(mktempdir demo)"
echo "cwd: $here"
echo "basename: $(basename "$here")"
[[ -d "$here" ]]
[[ "$(basename "$here")" == demo.* ]]
