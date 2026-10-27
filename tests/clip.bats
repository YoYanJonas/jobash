#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  CLIP_SH="$REPO_ROOT/features/clip/clip.sh"
  mkdir -p "$TEST_TMP/bin"
  cat >"$TEST_TMP/bin/clip.exe" <<EOF
#!/bin/sh
cat >"$TEST_TMP/clip.out"
EOF
  chmod +x "$TEST_TMP/bin/clip.exe"
  export PATH="$TEST_TMP/bin:/usr/bin:/bin"
}

teardown() {
  teardown_tmpdir
}

@test "clip copies stdin via clip.exe" {
  run bash -c 'printf "hi\n" | '"$CLIP_SH"
  [ "$status" -eq 0 ]
  [ "$output" = "copied" ]
  [ "$(cat "$TEST_TMP/clip.out")" = "hi" ]
}

@test "clip copies a file" {
  printf 'filedata\n' >"$TEST_TMP/a.txt"
  run "$CLIP_SH" "$TEST_TMP/a.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_TMP/clip.out")" = "filedata" ]
}

@test "clip errors on missing file" {
  run "$CLIP_SH" "$TEST_TMP/missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a file"* ]]
}

@test "clip errors when no backend" {
  run env PATH="/does/not/exist" /bin/bash "$CLIP_SH" <<<"x"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no clipboard backend"* ]]
}
