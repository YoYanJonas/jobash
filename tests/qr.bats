#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  QR_SH="$REPO_ROOT/features/qr/qr.sh"
  mkdir -p "$TEST_TMP/bin"
  cat >"$TEST_TMP/bin/qrencode" <<'EOF'
#!/bin/sh
echo "QR:$*"
EOF
  chmod +x "$TEST_TMP/bin/qrencode"
}

teardown() {
  teardown_tmpdir
}

@test "qr uses qrencode when available" {
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$QR_SH" "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello"* ]]
}

@test "qr errors without argument" {
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$QR_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "qr errors when backends missing" {
  run env PATH="/does/not/exist" /bin/bash "$QR_SH" hi
  [ "$status" -ne 0 ]
  [[ "$output" == *"need qrencode"* ]]
}
