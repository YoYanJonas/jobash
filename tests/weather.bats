#!/usr/bin/env bats

load test_helper

setup() {
  setup_tmpdir
  WEATHER_SH="$REPO_ROOT/features/weather/weather.sh"
  mkdir -p "$TEST_TMP/bin"
  cat >"$TEST_TMP/bin/curl" <<'EOF'
#!/bin/sh
echo "Tehran: +22C"
EOF
  chmod +x "$TEST_TMP/bin/curl"
}

teardown() {
  teardown_tmpdir
}

@test "weather prints curl response for a place" {
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$WEATHER_SH" Tehran
  [ "$status" -eq 0 ]
  [ "$output" = "Tehran: +22C" ]
}

@test "weather encodes spaces in place name" {
  cat >"$TEST_TMP/bin/curl" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >"${JOBASH_CURL_LOG:-/dev/null}"
echo "ok"
EOF
  export JOBASH_CURL_LOG="$TEST_TMP/curl.log"
  # rewrite curl to log URL from args
  cat >"$TEST_TMP/bin/curl" <<EOF
#!/bin/sh
echo "\$*" >"$TEST_TMP/curl.log"
echo "New York: +10C"
EOF
  chmod +x "$TEST_TMP/bin/curl"
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$WEATHER_SH" New York
  [ "$status" -eq 0 ]
  grep -q 'wttr.in/New+York' "$TEST_TMP/curl.log"
}

@test "weather errors when curl fails" {
  cat >"$TEST_TMP/bin/curl" <<'EOF'
#!/bin/sh
exit 22
EOF
  chmod +x "$TEST_TMP/bin/curl"
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$WEATHER_SH" Nowhere
  [ "$status" -ne 0 ]
  [[ "$output" == *"request failed"* ]]
}

@test "weather errors when curl missing" {
  run env PATH="/does/not/exist" /bin/bash "$WEATHER_SH" Tehran
  [ "$status" -ne 0 ]
  [[ "$output" == *"curl not found"* ]]
}

@test "weather errors without PLACE" {
  run env PATH="$TEST_TMP/bin:/usr/bin:/bin" "$WEATHER_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
