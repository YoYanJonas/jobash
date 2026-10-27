#!/usr/bin/env bats

load test_helper

@test "mktempdir creates named temp dir and cds into it" {
  run bash -c 'source "'"$REPO_ROOT"'/features/mktempdir/shell.sh"; mktempdir demo'
  [ "$status" -eq 0 ]
  [[ "$output" == */demo.* ]]
  [ -d "$output" ]
  rm -rf "$output"
}

@test "mktempdir without name still creates a directory" {
  run bash -c 'source "'"$REPO_ROOT"'/features/mktempdir/shell.sh"; mktempdir'
  [ "$status" -eq 0 ]
  [ -d "$output" ]
  rm -rf "$output"
}
