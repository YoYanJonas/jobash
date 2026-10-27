#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  EMPTY_SH="$REPO_ROOT/features/empty/empty.sh"
  mkdir -p "$TEST_TMP/empty-dir"
  : >"$TEST_TMP/empty-file"
  printf 'x\n' >"$TEST_TMP/full"
}

teardown() {
  teardown_tmpdir
}

@test "empty lists empty files and dirs" {
  run "$EMPTY_SH" "$TEST_TMP"
  [ "$status" -eq 0 ]
  [[ "$output" == *"empty-file"* ]]
  [[ "$output" == *"empty-dir"* ]]
  [[ "$output" != *"full"* ]]
}

@test "empty errors when none found" {
  rm -rf "$TEST_TMP/empty-dir" "$TEST_TMP/empty-file"
  run "$EMPTY_SH" "$TEST_TMP"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no empty"* ]]
}

@test "empty errors on missing directory" {
  run "$EMPTY_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}
