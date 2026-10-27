#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  WHICHALL_SH="$REPO_ROOT/features/whichall/whichall.sh"
  mkdir -p "$TEST_TMP/a" "$TEST_TMP/b"
  printf '#!/bin/sh\necho a\n' >"$TEST_TMP/a/tool"
  printf '#!/bin/sh\necho b\n' >"$TEST_TMP/b/tool"
  chmod +x "$TEST_TMP/a/tool" "$TEST_TMP/b/tool"
}

teardown() {
  teardown_tmpdir
}

@test "whichall lists every PATH match in order" {
  run env "PATH=$TEST_TMP/a:$TEST_TMP/b:/usr/bin:/bin" bash "$WHICHALL_SH" tool
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$TEST_TMP/a/tool" ]
  [ "${lines[1]}" = "$TEST_TMP/b/tool" ]
}

@test "whichall errors when command missing" {
  run env "PATH=$TEST_TMP/a:/usr/bin:/bin" bash "$WHICHALL_SH" nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}
