#!/usr/bin/env bash
# Shared setup for Jobash Bats tests.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

COUNT_SH="$REPO_ROOT/features/count/count.sh"
INSTALL_SH="$REPO_ROOT/install.sh"

load_jobash_libs() {
  # shellcheck source=../lib/common.sh
  source "$REPO_ROOT/lib/common.sh"
  # shellcheck source=../lib/features.sh
  source "$REPO_ROOT/lib/features.sh"
  # shellcheck source=../lib/bashrc.sh
  source "$REPO_ROOT/lib/bashrc.sh"
  # shellcheck source=../lib/install.sh
  source "$REPO_ROOT/lib/install.sh"
}

setup_tmpdir() {
  TEST_TMP="$(mktemp -d)"
  export TEST_TMP
}

teardown_tmpdir() {
  if [[ -n "${TEST_TMP:-}" && -d "$TEST_TMP" ]]; then
    rm -rf "$TEST_TMP"
  fi
}
