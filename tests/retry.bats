#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  RETRY_SH="$REPO_ROOT/features/retry/retry.sh"
}

teardown() {
  teardown_tmpdir
}

@test "retry succeeds after transient failures" {
  cat >"$TEST_TMP/flaky" <<EOF
#!/bin/sh
n=\$(cat "$TEST_TMP/n" 2>/dev/null || echo 0)
n=\$((n+1)); echo "\$n" >"$TEST_TMP/n"
[ "\$n" -ge 3 ]
EOF
  chmod +x "$TEST_TMP/flaky"
  run "$RETRY_SH" 5 0 "$TEST_TMP/flaky"
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_TMP/n")" = "3" ]
}

@test "retry fails after exhausting attempts" {
  run "$RETRY_SH" 2 0 false
  [ "$status" -ne 0 ]
  [[ "$output" == *"failed after 2 attempts"* ]]
}

@test "retry errors on bad args" {
  run "$RETRY_SH" 0 1 true
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
