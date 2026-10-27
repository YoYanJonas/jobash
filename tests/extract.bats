#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  EXTRACT_SH="$REPO_ROOT/features/extract/extract.sh"
  mkdir -p "$TEST_TMP/payload"
  printf 'hi\n' >"$TEST_TMP/payload/hello.txt"
}

teardown() {
  teardown_tmpdir
}

@test "extract unpacks tar.gz" {
  tar -czf "$TEST_TMP/demo.tar.gz" -C "$TEST_TMP" payload
  rm -rf "$TEST_TMP/payload"
  (
    cd "$TEST_TMP"
    run "$EXTRACT_SH" demo.tar.gz
    [ "$status" -eq 0 ]
  )
  [ -f "$TEST_TMP/payload/hello.txt" ]
}

@test "extract unpacks zip" {
  (
    cd "$TEST_TMP"
    zip -q -r demo.zip payload
    rm -rf payload
    run "$EXTRACT_SH" demo.zip
    [ "$status" -eq 0 ]
  )
  [ -f "$TEST_TMP/payload/hello.txt" ]
}

@test "extract errors on missing file" {
  run "$EXTRACT_SH" "$TEST_TMP/missing.tar.gz"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a file"* ]]
}

@test "extract errors on unsupported extension" {
  printf 'x\n' >"$TEST_TMP/file.txt"
  run "$EXTRACT_SH" "$TEST_TMP/file.txt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported"* ]]
}
