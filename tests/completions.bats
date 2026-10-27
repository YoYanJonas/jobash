#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  PREFIX="$TEST_TMP/jobash"
  BASHRC="$TEST_TMP/bashrc"
  printf '%s\n' '# existing config' >"$BASHRC"
}

teardown() {
  teardown_tmpdir
}

@test "every feature has a completions/<id>.bash" {
  local id missing=0
  for id in "$REPO_ROOT"/features/*/meta.conf; do
    id="$(basename "$(dirname "$id")")"
    if [[ ! -f "$REPO_ROOT/completions/${id}.bash" ]]; then
      echo "missing completions/${id}.bash" >&2
      missing=1
    fi
  done
  [ "$missing" -eq 0 ]
  [ -f "$REPO_ROOT/completions/jobash.bash" ]
}

@test "install copies feature and jobash completions" {
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count,mkcd
  [ "$status" -eq 0 ]
  [ -f "$PREFIX/completions/count.bash" ]
  [ -f "$PREFIX/completions/mkcd.bash" ]
  [ -f "$PREFIX/completions/jobash.bash" ]
  grep -q 'JOBASH_HOME/completions' "$BASHRC"
}

@test "bashrc-sourced completions register complete for count" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  run bash --noprofile --rcfile "$BASHRC" -i -c 'complete -p count'
  [ "$status" -eq 0 ]
  [[ "$output" == *"count"* ]]
}

@test "uninstall removes feature completion file" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count,bak
  run "$REPO_ROOT/uninstall.sh" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX/completions/count.bash" ]
  [ -f "$PREFIX/completions/bak.bash" ]
}
