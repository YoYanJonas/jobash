#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  GITIGNORE_SH="$REPO_ROOT/features/gitignore/gitignore.sh"
  git -C "$TEST_TMP" init -q
}

teardown() {
  teardown_tmpdir
}

@test "gitignore creates and appends pattern at repo root" {
  (
    cd "$TEST_TMP"
    run "$GITIGNORE_SH" "node_modules/"
    [ "$status" -eq 0 ]
    [[ "$output" == *"added"* ]]
  )
  grep -Fxq "node_modules/" "$TEST_TMP/.gitignore"
}

@test "gitignore is idempotent for the same pattern" {
  (
    cd "$TEST_TMP"
    "$GITIGNORE_SH" "dist/" >/dev/null
    run "$GITIGNORE_SH" "dist/"
    [ "$status" -eq 0 ]
    [[ "$output" == *"already present"* ]]
  )
  lines="$(grep -cxF 'dist/' "$TEST_TMP/.gitignore")"
  [ "$lines" -eq 1 ]
}

@test "gitignore finds nearest ignore from subdirectory" {
  mkdir -p "$TEST_TMP/sub"
  printf 'root\n' >"$TEST_TMP/.gitignore"
  (
    cd "$TEST_TMP/sub"
    run "$GITIGNORE_SH" "*.log"
    [ "$status" -eq 0 ]
  )
  grep -Fxq "*.log" "$TEST_TMP/.gitignore"
}

@test "gitignore errors outside repo without ignore file" {
  outside="$(mktemp -d)"
  (
    cd "$outside"
    run "$GITIGNORE_SH" "x"
    [ "$status" -ne 0 ]
    [[ "$output" == *"no .gitignore"* ]]
  )
  rm -rf "$outside"
}
