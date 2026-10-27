#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  mkdir -p "$TEST_TMP/bin"
}

teardown() {
  teardown_tmpdir
}

@test "pathadd prepends directory to PATH" {
  run bash -c 'source "'"$REPO_ROOT"'/features/pathadd/shell.sh"; pathadd "'"$TEST_TMP"'/bin"; echo "$PATH"'
  [ "$status" -eq 0 ]
  [[ "$output" == "$TEST_TMP/bin:"* ]] || [[ "$output" == *$'\n'"$TEST_TMP/bin:"* ]]
}

@test "pathadd is idempotent for the same directory" {
  run bash -c 'source "'"$REPO_ROOT"'/features/pathadd/shell.sh"; pathadd "'"$TEST_TMP"'/bin" >/dev/null; pathadd "'"$TEST_TMP"'/bin" >/dev/null; echo "$PATH" | tr ":" "\n" | grep -cxF "'"$TEST_TMP"'/bin"'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "pathadd errors on missing directory" {
  run bash -c 'source "'"$REPO_ROOT"'/features/pathadd/shell.sh"; pathadd "'"$TEST_TMP"'/missing"'
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}
