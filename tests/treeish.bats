#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  TREEISH_SH="$REPO_ROOT/features/treeish/treeish.sh"
  mkdir -p "$TEST_TMP/a/b" "$TEST_TMP/c"
  touch "$TEST_TMP/a/x" "$TEST_TMP/a/b/nested-leaf" "$TEST_TMP/c/z"
}

teardown() {
  teardown_tmpdir
}

@test "treeish prints root and children within depth" {
  run "$TREEISH_SH" "$TEST_TMP" 1
  [ "$status" -eq 0 ]
  [[ "$output" == *"a"* ]]
  [[ "$output" == *"c"* ]]
  [[ "$output" != *"nested-leaf"* ]]
}

@test "treeish deeper depth includes nested files" {
  run "$TREEISH_SH" "$TEST_TMP" 2
  [ "$status" -eq 0 ]
  [[ "$output" == *"nested-leaf"* ]] || [[ "$output" == *"b"* ]]
}

@test "treeish errors on missing directory" {
  run "$TREEISH_SH" "$TEST_TMP/missing" 1
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}

@test "treeish errors on bad depth" {
  run "$TREEISH_SH" "$TEST_TMP" abc
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
