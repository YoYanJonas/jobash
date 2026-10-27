#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  SC_SH="$REPO_ROOT/features/symlink-check/symlink-check.sh"
  ln -s "$TEST_TMP/missing-target" "$TEST_TMP/broken"
  ln -s "$TEST_TMP" "$TEST_TMP/ok-link"
}

teardown() {
  teardown_tmpdir
}

@test "symlink-check reports broken links only" {
  run "$SC_SH" "$TEST_TMP"
  [ "$status" -eq 0 ]
  [[ "$output" == *"broken"* ]]
  [[ "$output" != *"ok-link"* ]]
}

@test "symlink-check errors when none broken" {
  rm -f "$TEST_TMP/broken"
  run "$SC_SH" "$TEST_TMP"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no broken symlinks"* ]]
}

@test "symlink-check errors on missing directory" {
  run "$SC_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}
