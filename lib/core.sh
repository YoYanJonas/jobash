#!/usr/bin/env bash
# Core Jobash CLI install: version stamp + bin/jobash hub.
# shellcheck shell=bash

jobash_git_version() {
  local root="$1"
  local ver=""

  if command -v git >/dev/null 2>&1 && [[ -d "$root/.git" || -f "$root/.git" ]]; then
    ver="$(git -C "$root" describe --tags --always --dirty 2>/dev/null || true)"
    if [[ -z "$ver" ]]; then
      ver="$(git -C "$root" rev-parse --short HEAD 2>/dev/null || true)"
    fi
  fi
  printf '%s\n' "${ver:-unknown}"
}

jobash_core_write_meta() {
  local root="$1" prefix="$2"
  local ver
  jobash_install_ensure_prefix "$prefix"
  ver="$(jobash_git_version "$root")"
  printf '%s\n' "$ver" >"$prefix/VERSION"
  printf '%s\n' "$root" >"$prefix/SOURCE"
  jobash_info "version $ver (source $root)"
}

# Install/refresh the jobash hub binary and stamp VERSION + SOURCE.
jobash_install_core() {
  local root="$1" prefix="$2"
  local src dest

  src="$root/bin/jobash"
  [[ -f "$src" ]] || jobash_die "missing core CLI: $src"
  jobash_install_ensure_prefix "$prefix"
  dest="$prefix/bin/jobash"
  cp "$src" "$dest"
  chmod +x "$dest"
  jobash_core_write_meta "$root" "$prefix"
  jobash_info "installed jobash -> $dest"
}
