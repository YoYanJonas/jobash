#!/usr/bin/env bats

load test_helper

setup() {
  ENVGREP_SH="$REPO_ROOT/features/envgrep/envgrep.sh"
}

@test "envgrep matches exported variables" {
  run env JOBASH_TEST_MARK=abc "$ENVGREP_SH" JOBASH_TEST_MARK
  [ "$status" -eq 0 ]
  [[ "$output" == *"JOBASH_TEST_MARK=abc"* ]]
}

@test "envgrep errors when nothing matches" {
  run env -i PATH="$PATH" "$ENVGREP_SH" ZZZ_NO_SUCH_VAR_ZZZ
  [ "$status" -ne 0 ]
  [[ "$output" == *"no matches"* ]]
}

@test "envgrep errors without pattern" {
  run "$ENVGREP_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
