#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  NOTE_SH="$REPO_ROOT/features/note/note.sh"
  export JOBASH_NOTES_FILE="$TEST_TMP/notes.txt"
}

teardown() {
  teardown_tmpdir
}

@test "note appends dated lines to notes file" {
  run "$NOTE_SH" hello world
  [ "$status" -eq 0 ]
  [ "$output" = "$JOBASH_NOTES_FILE" ]
  [ -f "$JOBASH_NOTES_FILE" ]
  grep -q 'hello world' "$JOBASH_NOTES_FILE"
  run "$NOTE_SH" second
  [ "$status" -eq 0 ]
  lines="$(wc -l <"$JOBASH_NOTES_FILE")"
  lines=${lines//[[:space:]]/}
  [ "$lines" = "2" ]
}

@test "note creates parent directories" {
  export JOBASH_NOTES_FILE="$TEST_TMP/a/b/notes.txt"
  run "$NOTE_SH" nested
  [ "$status" -eq 0 ]
  [ -f "$JOBASH_NOTES_FILE" ]
  grep -q nested "$JOBASH_NOTES_FILE"
}

@test "note errors without message" {
  run "$NOTE_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
