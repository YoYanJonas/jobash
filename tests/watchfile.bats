#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  WATCH_SH="$REPO_ROOT/features/watchfile/watchfile.sh"
  WATCH_PID=""
  printf 'one\n' >"$TEST_TMP/f.txt"
}

teardown() {
  if [[ -n "${WATCH_PID:-}" ]]; then
    kill "$WATCH_PID" 2>/dev/null || true
    wait "$WATCH_PID" 2>/dev/null || true
  fi
  teardown_tmpdir
}

@test "watchfile runs command once on change" {
  JOBASH_WATCH_ONCE=1 JOBASH_WATCH_INTERVAL=0.1 \
    "$WATCH_SH" "$TEST_TMP/f.txt" bash -c 'echo changed >"'"$TEST_TMP"'/out"' &
  WATCH_PID=$!
  sleep 0.2
  printf 'two-lines\n' >"$TEST_TMP/f.txt"

  local i
  for i in $(seq 1 50); do
    if [[ -f "$TEST_TMP/out" ]]; then
      break
    fi
    sleep 0.1
  done

  [ -f "$TEST_TMP/out" ]
  [ "$(cat "$TEST_TMP/out")" = "changed" ]
  wait "$WATCH_PID" || true
  WATCH_PID=""
}

@test "watchfile errors when file missing" {
  run "$WATCH_SH" "$TEST_TMP/missing" true
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "watchfile errors without command" {
  run "$WATCH_SH" "$TEST_TMP/f.txt"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
