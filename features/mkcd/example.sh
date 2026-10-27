#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shell.sh
source "$ROOT/shell.sh"

base="$(mktemp -d)"
trap 'rm -rf "$base"' EXIT

echo "\$ mkcd $base/work/new-app"
here="$(mkcd "$base/work/new-app")"
echo "cwd: $here"
[[ -d "$here" ]]
[[ "$here" == *"/work/new-app" ]]
