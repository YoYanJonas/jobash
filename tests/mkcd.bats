#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
}

teardown() {
  teardown_tmpdir
}

@test "mkcd creates nested dir and cds into it" {
  run bash -c 'source "'"$REPO_ROOT"'/features/mkcd/shell.sh"; mkcd "'"$TEST_TMP"'/a/b"'
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_TMP/a/b" ]
  [ -d "$TEST_TMP/a/b" ]
}

@test "mkcd errors when DIR missing" {
  run bash -c 'source "'"$REPO_ROOT"'/features/mkcd/shell.sh"; mkcd'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
