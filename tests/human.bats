#!/usr/bin/env bats

load test_helper

setup() {
  HUMAN_SH="$REPO_ROOT/features/human/human.sh"
}

@test "human formats bytes" {
  run "$HUMAN_SH" 1536000
  [ "$status" -eq 0 ]
  [[ "$output" == *"MB"* ]] || [[ "$output" == *"1.5MB"* ]] || [[ "$output" == 1.5* ]]
}

@test "human formats seconds" {
  run "$HUMAN_SH" -s 90
  [ "$status" -eq 0 ]
  [[ "$output" == *"1m"* ]]
}

@test "human errors on bad number" {
  run "$HUMAN_SH" nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
