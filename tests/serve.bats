#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  SERVE_SH="$REPO_ROOT/features/serve/serve.sh"
  SERVE_PID=""
  printf 'hello-serve\n' >"$TEST_TMP/index.html"
}

teardown() {
  if [[ -n "${SERVE_PID:-}" ]]; then
    kill "$SERVE_PID" 2>/dev/null || true
    wait "$SERVE_PID" 2>/dev/null || true
  fi
  teardown_tmpdir
}

@test "serve answers HTTP for cwd files" {
  (
    cd "$TEST_TMP"
    "$SERVE_SH" 8766 &
    echo $! >"$TEST_TMP/pid"
  )
  SERVE_PID="$(cat "$TEST_TMP/pid")"
  local ok=0 i
  for i in $(seq 1 40); do
    if out="$(curl -fsS "http://127.0.0.1:8766/index.html" 2>/dev/null)"; then
      [[ "$out" == *"hello-serve"* ]]
      ok=1
      break
    fi
    sleep 0.05
  done
  [ "$ok" -eq 1 ]
}

@test "serve errors on bad port" {
  run "$SERVE_SH" abc
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "serve errors when python3 missing" {
  run env PATH="/does/not/exist" /bin/bash "$SERVE_SH" 8767
  [ "$status" -ne 0 ]
  [[ "$output" == *"python3 not found"* ]]
}
