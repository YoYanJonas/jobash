#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  PREFIX="$TEST_TMP/jobash"
  BASHRC="$TEST_TMP/bashrc"
  UNINSTALL_SH="$REPO_ROOT/uninstall.sh"
  printf '%s\n' '# existing config' >"$BASHRC"
}

teardown() {
  teardown_tmpdir
}

@test "uninstall --all removes bins, bashrc block, and prefix" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count,mktempdir
  [ -x "$PREFIX/bin/count" ]
  [ -f "$PREFIX/shell/mktempdir.sh" ]
  run "$UNINSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX" ]
  ! grep -q 'JOBASH' "$BASHRC"
  grep -q 'existing config' "$BASHRC"
}

@test "uninstall --features removes only selected bins and keeps others" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count,bak
  run "$UNINSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX/bin/count" ]
  [ -x "$PREFIX/bin/bak" ]
  grep -qxF '# >>> JOBASH' "$BASHRC"
}

@test "uninstall last feature also wipes bashrc block and prefix" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  run "$UNINSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX" ]
  ! grep -q 'JOBASH' "$BASHRC"
}

@test "uninstall choose menu lists only installed features" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  # choose → pick count by id → then quit
  run bash -c 'printf "2\ncount\n0\n" | NO_COLOR=1 JOBASH_PREFIX="'"$PREFIX"'" JOBASH_BASHRC="'"$BASHRC"'" "'"$UNINSTALL_SH"'"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installed features"* ]]
  [[ "$output" == *"count"* ]]
  ! grep -E '^\s+[0-9]+\)\s+bak\b' <<<"$output"
  [ ! -e "$PREFIX/bin/count" ]
  ! grep -q 'JOBASH' "$BASHRC"
}

@test "uninstall interactive warns on bad input then stays open" {
  run bash -c 'printf "9\n8\n7\n0\n" | NO_COLOR=1 "'"$UNINSTALL_SH"'"'
  [ "$status" -eq 0 ]
  local warns
  warns="$(grep -c 'check options again. bad request!' <<<"$output" || true)"
  [ "$warns" -eq 3 ]
  [[ "$output" == *"[+] bye"* ]] || [[ "$output" == *"bye"* ]]
}

@test "install --uninstall still performs full cleanup" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --all
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --uninstall
  [ "$status" -eq 0 ]
  [ ! -e "$PREFIX" ]
  ! grep -q 'JOBASH' "$BASHRC"
}
