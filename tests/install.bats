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

@test "install --all creates bin/count and JOBASH markers" {
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  [ "$status" -eq 0 ]
  [ -x "$PREFIX/bin/count" ]
  grep -qxF '# >>> JOBASH' "$BASHRC"
  grep -qxF '# <<< JOBASH' "$BASHRC"
  grep -q 'existing config' "$BASHRC"
}

@test "install re-run does not duplicate JOBASH markers" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  local begins ends
  begins="$(grep -cxF '# >>> JOBASH' "$BASHRC")"
  ends="$(grep -cxF '# <<< JOBASH' "$BASHRC")"
  [ "$begins" -eq 1 ]
  [ "$ends" -eq 1 ]
}

@test "install --example does not touch bashrc" {
  local before after
  before="$(cat "$BASHRC")"
  run "$INSTALL_SH" --example count
  [ "$status" -eq 0 ]
  after="$(cat "$BASHRC")"
  [ "$before" = "$after" ]
  [ ! -e "$PREFIX/bin/count" ]
}

@test "install --uninstall removes bin and JOBASH block" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --uninstall
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX/bin/count" ]
  ! grep -q 'JOBASH' "$BASHRC"
  grep -q 'existing config' "$BASHRC"
}

@test "install --features count installs only count" {
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [ -x "$PREFIX/bin/count" ]
  run "$PREFIX/bin/count" -f "$PREFIX/bin"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "install shell feature copies shell snippet and bashrc sources it" {
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features mktempdir
  [ "$status" -eq 0 ]
  [ -f "$PREFIX/shell/mktempdir.sh" ]
  grep -q 'JOBASH_HOME/shell' "$BASHRC"
  [ ! -e "$PREFIX/bin/mktempdir" ]
}

@test "install skips features already present under prefix" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  printf '\n# stamp\n' >>"$PREFIX/bin/count"
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip count"* ]]
  grep -q '# stamp' "$PREFIX/bin/count"
}
