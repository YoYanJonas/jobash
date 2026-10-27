#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  TRASH_SH="$REPO_ROOT/features/trash/trash.sh"
  export JOBASH_TRASH_DIR="$TEST_TMP/trash"
  printf 'data\n' >"$TEST_TMP/old.log"
}

teardown() {
  teardown_tmpdir
}

@test "trash moves a file into trash dir" {
  run "$TRASH_SH" "$TEST_TMP/old.log"
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_TMP/old.log" ]
  [ -f "$JOBASH_TRASH_DIR/old.log" ]
}

@test "trash renames on name collision" {
  mkdir -p "$JOBASH_TRASH_DIR"
  printf 'existing\n' >"$JOBASH_TRASH_DIR/old.log"
  run "$TRASH_SH" "$TEST_TMP/old.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$JOBASH_TRASH_DIR/old.log."* ]]
  [ -f "$output" ]
}

@test "trash errors when path missing" {
  run "$TRASH_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}
