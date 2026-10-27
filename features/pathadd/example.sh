#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shell.sh
source "$ROOT/shell.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
printf '#!/bin/sh\necho ok\n' >"$tmp/bin/demo-cmd"
chmod +x "$tmp/bin/demo-cmd"

echo "\$ pathadd $tmp/bin"
pathadd "$tmp/bin"
command -v demo-cmd
demo-cmd
