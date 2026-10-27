#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  BAK_SH="$REPO_ROOT/features/bak/bak.sh"
  printf 'data\n' >"$TEST_TMP/file.txt"
  mkdir -p "$TEST_TMP/dir"
  printf 'x\n' >"$TEST_TMP/dir/a.txt"
}

teardown() {
  teardown_tmpdir
}

@test "bak copies file to timestamped sibling" {
  run "$BAK_SH" "$TEST_TMP/file.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == "$TEST_TMP/file.txt."*.bak ]]
  [ -f "$output" ]
  [ "$(cat "$output")" = "data" ]
  [ -f "$TEST_TMP/file.txt" ]
}

@test "bak copies directory with cp -a" {
  run "$BAK_SH" "$TEST_TMP/dir"
  [ "$status" -eq 0 ]
  [ -d "$output" ]
  [ -f "$output/a.txt" ]
}

@test "bak errors when path missing" {
  run "$BAK_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}
