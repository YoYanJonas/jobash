#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shell.sh
source "$ROOT/shell.sh"
repo="$(mktemp -d)"
trap 'rm -rf "$repo"' EXIT
git -C "$repo" init -q
mkdir -p "$repo/sub/dir"
cd "$repo/sub/dir"
echo "\$ gitroot"
gitroot
