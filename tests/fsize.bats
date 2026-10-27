#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  FSIZE_SH="$REPO_ROOT/features/fsize/fsize.sh"
  dd if=/dev/zero of="$TEST_TMP/blob" bs=1024 count=2 status=none 2>/dev/null \
    || dd if=/dev/zero of="$TEST_TMP/blob" bs=1024 count=2 2>/dev/null
  mkdir -p "$TEST_TMP/dir"
  printf 'x\n' >"$TEST_TMP/dir/a"
}

teardown() {
  teardown_tmpdir
}

@test "fsize reports size for a file" {
  run "$FSIZE_SH" "$TEST_TMP/blob"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\t'"$TEST_TMP/blob" ]] || [[ "$output" == *"	$TEST_TMP/blob" ]]
  [[ "$output" =~ ^[0-9.]+[KMGT]?B?[[:space:]] ]] || [[ "$output" =~ ^[0-9.]+[KkMmGgTt] ]]
}

@test "fsize reports size for a directory" {
  run "$FSIZE_SH" "$TEST_TMP/dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_TMP/dir"* ]]
}

@test "fsize errors when path missing" {
  run "$FSIZE_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "fsize errors without PATH arg" {
  run "$FSIZE_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
