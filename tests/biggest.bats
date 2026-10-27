#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  BIGGEST_SH="$REPO_ROOT/features/biggest/biggest.sh"
  printf 'a\n' >"$TEST_TMP/small"
  dd if=/dev/zero of="$TEST_TMP/big" bs=1024 count=4 status=none 2>/dev/null \
    || dd if=/dev/zero of="$TEST_TMP/big" bs=1024 count=4 2>/dev/null
  printf 'bb\n' >"$TEST_TMP/mid"
}

teardown() {
  teardown_tmpdir
}

@test "biggest lists files by size descending" {
  run "$BIGGEST_SH" "$TEST_TMP" 2
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"$TEST_TMP/big"* ]]
}

@test "biggest errors on missing directory" {
  run "$BIGGEST_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a directory"* ]]
}

@test "biggest errors on bad N" {
  run "$BIGGEST_SH" "$TEST_TMP" 0
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
