#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  git -C "$TEST_TMP" init -q
  mkdir -p "$TEST_TMP/sub/dir"
}

teardown() {
  teardown_tmpdir
}

@test "gitroot cds to repository root" {
  run bash -c 'source "'"$REPO_ROOT"'/features/gitroot/shell.sh"; cd "'"$TEST_TMP"'/sub/dir"; gitroot'
  [ "$status" -eq 0 ]
  # Compare realpaths to avoid /tmp vs /var/tmp differences
  [ "$(realpath "$output")" = "$(realpath "$TEST_TMP")" ]
}

@test "gitroot errors outside a repository" {
  local outside
  outside="$(mktemp -d)"
  run bash -c 'source "'"$REPO_ROOT"'/features/gitroot/shell.sh"; cd "'"$outside"'"; gitroot'
  [ "$status" -ne 0 ]
  [[ "$output" == *"not inside a git repository"* ]]
  rm -rf "$outside"
}
