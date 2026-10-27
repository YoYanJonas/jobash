#!/usr/bin/env bats

load test_helper

setup() {
  KILLPORT_SH="$REPO_ROOT/features/killport/killport.sh"
  LISTEN_PID=""
}

teardown() {
  if [[ -n "${LISTEN_PID:-}" ]]; then
    kill "$LISTEN_PID" 2>/dev/null || true
    wait "$LISTEN_PID" 2>/dev/null || true
  fi
}

start_listener() {
  local portfile="$1"
  python3 - "$portfile" <<'PY' &
import socket, sys, time
path = sys.argv[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 0))
open(path, "w").write(str(s.getsockname()[1]))
s.listen(1)
time.sleep(60)
PY
  LISTEN_PID=$!
  for _ in $(seq 1 50); do
    [[ -s "$portfile" ]] && break
    sleep 0.05
  done
}

@test "killport kills a live listener" {
  local portfile port
  portfile="$(mktemp)"
  start_listener "$portfile"
  port="$(cat "$portfile")"
  [[ "$port" =~ ^[0-9]+$ ]]

  run "$KILLPORT_SH" "$port"
  [ "$status" -eq 0 ]
  [[ "$output" == *"killed pid"* ]]

  # Process should be gone (or exiting)
  sleep 0.2
  if kill -0 "$LISTEN_PID" 2>/dev/null; then
    # still listed briefly; wait a bit more
    sleep 0.5
  fi
  ! kill -0 "$LISTEN_PID" 2>/dev/null
  LISTEN_PID=""
  rm -f "$portfile"
}

@test "killport errors when nothing listens" {
  local p
  for p in 58441 58442 58443; do
    run "$KILLPORT_SH" "$p"
    if [[ "$status" -ne 0 ]]; then
      [[ "$output" == *"nothing listening"* ]]
      return 0
    fi
  done
  false
}

@test "killport errors on bad PORT" {
  run "$KILLPORT_SH" abc
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "killport errors when ss missing" {
  run env PATH="/does/not/exist" /bin/bash "$KILLPORT_SH" 8080
  [ "$status" -ne 0 ]
  [[ "$output" == *"ss not found"* ]]
}
