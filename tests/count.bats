#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  mkdir -p "$TEST_TMP/a" "$TEST_TMP/b"
  touch "$TEST_TMP/one.txt" "$TEST_TMP/two.txt" "$TEST_TMP/three.txt"
}

teardown() {
  teardown_tmpdir
}

@test "count reports files and dirs" {
  run "$COUNT_SH" "$TEST_TMP"
  [ "$status" -eq 0 ]
  [ "$output" = "3 files, 2 dirs" ]
}

@test "count -f reports files only" {
  run "$COUNT_SH" -f "$TEST_TMP"
  [ "$status" -eq 0 ]
  [ "$output" = "3" ]
}

@test "count -d reports dirs only" {
  run "$COUNT_SH" -d "$TEST_TMP"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "count errors on non-directory" {
  run "$COUNT_SH" "$TEST_TMP/one.txt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}

@test "count errors when DIR missing" {
  run "$COUNT_SH"
  [ "$status" -ne 0 ]
}
