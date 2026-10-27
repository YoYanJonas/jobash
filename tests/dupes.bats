#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  DUPES_SH="$REPO_ROOT/features/dupes/dupes.sh"
  printf 'same\n' >"$TEST_TMP/a.txt"
  printf 'same\n' >"$TEST_TMP/b.txt"
  printf 'other\n' >"$TEST_TMP/c.txt"
}

teardown() {
  teardown_tmpdir
}

@test "dupes finds matching file contents" {
  run "$DUPES_SH" "$TEST_TMP"
  [ "$status" -eq 0 ]
  [[ "$output" == *"a.txt"* ]]
  [[ "$output" == *"b.txt"* ]]
  [[ "$output" != *"c.txt"* ]]
}

@test "dupes errors when no duplicates" {
  rm -f "$TEST_TMP/b.txt"
  run "$DUPES_SH" "$TEST_TMP"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no duplicates"* ]]
}

@test "dupes errors on missing directory" {
  run "$DUPES_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}
