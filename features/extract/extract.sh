#!/usr/bin/env bash
# extract: unpack common archives by file extension
# Usage: extract ARCHIVE
set -euo pipefail

usage() {
  echo "Usage: extract ARCHIVE" >&2
  echo "Supported: .zip .tar .tar.gz .tgz .tar.bz2 .tbz2 .tar.xz .txz .gz .bz2 .xz" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
archive="$1"

if [[ ! -f "$archive" ]]; then
  echo "extract: not a file: $archive" >&2
  exit 1
fi

# Lowercase name for matching (bash 4+)
name="${archive,,}"

case "$name" in
  *.tar.gz|*.tgz)
    tar -xzf "$archive"
    ;;
  *.tar.bz2|*.tbz2)
    tar -xjf "$archive"
    ;;
  *.tar.xz|*.txz)
    tar -xJf "$archive"
    ;;
  *.tar)
    tar -xf "$archive"
    ;;
  *.zip)
    unzip -q "$archive"
    ;;
  *.gz)
    gunzip -k "$archive"
    ;;
  *.bz2)
    bunzip2 -k "$archive"
    ;;
  *.xz)
    unxz -k "$archive"
    ;;
  *)
    echo "extract: unsupported archive: $archive" >&2
    exit 1
    ;;
esac

echo "extracted: $archive"
