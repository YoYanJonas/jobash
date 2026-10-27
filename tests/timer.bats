#!/usr/bin/env bats

load test_helper

setup() {
  TIMER_SH="$REPO_ROOT/features/timer/timer.sh"
}

@test "timer reports elapsed time and success exit" {
  run "$TIMER_SH" true
  [ "$status" -eq 0 ]
  [[ "$output" == *"timer:"*"s (exit 0)"* ]]
}

@test "timer preserves failure exit code" {
  run "$TIMER_SH" false
  [ "$status" -ne 0 ]
  [[ "$output" == *"(exit "* ]]
}

@test "timer errors without command" {
  run "$TIMER_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
