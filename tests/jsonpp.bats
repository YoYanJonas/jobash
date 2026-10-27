#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  JSONPP_SH="$REPO_ROOT/features/jsonpp/jsonpp.sh"
  printf '{"a":1,"b":[2,3]}\n' >"$TEST_TMP/x.json"
}

teardown() {
  teardown_tmpdir
}

@test "jsonpp pretty-prints a file" {
  run "$JSONPP_SH" "$TEST_TMP/x.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"a": 1'* ]]
  [[ "$output" == *'"b":'* ]]
}

@test "jsonpp pretty-prints stdin" {
  run bash -c 'printf "%s" "{\"x\":true}" | "'"$JSONPP_SH"'"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"x": true'* ]]
}

@test "jsonpp errors on invalid JSON" {
  printf 'not-json\n' >"$TEST_TMP/bad.json"
  run "$JSONPP_SH" "$TEST_TMP/bad.json"
  [ "$status" -ne 0 ]
}

@test "jsonpp errors on missing file" {
  run "$JSONPP_SH" "$TEST_TMP/missing.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a file"* ]]
}
