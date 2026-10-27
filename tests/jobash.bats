#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  PREFIX="$TEST_TMP/jobash"
  BASHRC="$TEST_TMP/bashrc"
  JOBASH_BIN="$REPO_ROOT/bin/jobash"
  printf '%s\n' '# existing config' >"$BASHRC"
}

teardown() {
  teardown_tmpdir
}

@test "install stamps VERSION SOURCE and installs jobash hub" {
  run "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  [ "$status" -eq 0 ]
  [ -x "$PREFIX/bin/jobash" ]
  [ -f "$PREFIX/VERSION" ]
  [ -f "$PREFIX/SOURCE" ]
  [ "$(cat "$PREFIX/SOURCE")" = "$REPO_ROOT" ]
  [[ -n "$(cat "$PREFIX/VERSION")" ]]
  [[ "$(cat "$PREFIX/VERSION")" != "unknown" ]] || skip "git version unavailable"
}

@test "jobash menu shows version and quits on 0" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  local ver
  ver="$(tr -d '\n' <"$PREFIX/VERSION")"
  run bash -c 'printf "0\n" | NO_COLOR=1 JOBASH_HOME="'"$PREFIX"'" JOBASH_BASHRC="'"$BASHRC"'" "'"$PREFIX/bin/jobash"'"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"$ver"* ]]
  [[ "$output" == *"installed"* ]]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"uninstall"* ]]
  [[ "$output" == *"docs"* ]]
  [[ "$output" == *"[+] bye"* ]] || [[ "$output" == *"bye"* ]]
}

@test "jobash installed list then back then quit" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  run bash -c 'printf "1\n0\n0\n" | NO_COLOR=1 JOBASH_HOME="'"$PREFIX"'" JOBASH_BASHRC="'"$BASHRC"'" "'"$PREFIX/bin/jobash"'"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installed features"* ]]
  [[ "$output" == *"count"* ]]
}

@test "jobash docs runs example then back to hub" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  # docs → count → back → quit
  run bash -c 'printf "4\ncount\n0\n0\n" | NO_COLOR=1 JOBASH_HOME="'"$PREFIX"'" JOBASH_BASHRC="'"$BASHRC"'" "'"$PREFIX/bin/jobash"'"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs"* ]]
  [[ "$output" == *"example done"* ]]
  [[ "$output" == *"[+] bye"* ]] || [[ "$output" == *"bye"* ]]
}

@test "jobash install submenu returns to hub on quit" {
  "$INSTALL_SH" --prefix "$PREFIX" --bashrc "$BASHRC" --features count
  # hub install → installer quit → hub quit
  run bash -c 'printf "2\n0\n0\n" | NO_COLOR=1 JOBASH_HOME="'"$PREFIX"'" JOBASH_BASHRC="'"$BASHRC"'" "'"$PREFIX/bin/jobash"'"'
  [ "$status" -eq 0 ]
  # installer bye then hub bye
  local byes
  byes="$(grep -c 'bye' <<<"$output" || true)"
  [ "$byes" -ge 2 ]
}
