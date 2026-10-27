#!/usr/bin/env bats

load test_helper

setup() {
  URLENC_SH="$REPO_ROOT/features/urlenc/urlenc.sh"
  URLDEC_SH="$REPO_ROOT/features/urldec/urldec.sh"
}

@test "urlenc encodes spaces and punctuation" {
  run "$URLENC_SH" 'a b=c'
  [ "$status" -eq 0 ]
  [ "$output" = "a%20b%3Dc" ]
}

@test "urldec decodes percent sequences" {
  run "$URLDEC_SH" 'a%20b%3Dc'
  [ "$status" -eq 0 ]
  [ "$output" = "a b=c" ]
}

@test "urlenc/urldec round-trip" {
  enc="$("$URLENC_SH" 'hello world!')"
  run "$URLDEC_SH" "$enc"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world!" ]
}

@test "urlenc errors without arg" {
  run "$URLENC_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
