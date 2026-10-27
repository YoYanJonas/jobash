#!/usr/bin/env bats

load test_helper

setup() {
  PORTS_SH="$REPO_ROOT/features/ports/ports.sh"
  LISTEN_PID=""
}

teardown() {
  if [[ -n "${LISTEN_PID:-}" ]]; then
    kill "$LISTEN_PID" 2>/dev/null || true
    wait "$LISTEN_PID" 2>/dev/null || true
  fi
}

@test "ports lists a live listening port when filtered" {
  local portfile port
  portfile="$(mktemp)"
  python3 - "$portfile" <<'PY' &
import socket, sys, time
path = sys.argv[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 0))
port = s.getsockname()[1]
open(path, "w").write(str(port))
s.listen(1)
time.sleep(60)
PY
  LISTEN_PID=$!
  for _ in $(seq 1 50); do
    [[ -s "$portfile" ]] && break
    sleep 0.05
  done
  port="$(cat "$portfile")"
  [[ "$port" =~ ^[0-9]+$ ]]

  run "$PORTS_SH" "$port"
  [ "$status" -eq 0 ]
  [[ "$output" == "$port"* ]]
  rm -f "$portfile"
}

@test "ports without filter includes a live listening port" {
  local portfile port
  portfile="$(mktemp)"
  python3 - "$portfile" <<'PY' &
import socket, sys, time
path = sys.argv[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 0))
port = s.getsockname()[1]
open(path, "w").write(str(port))
s.listen(1)
time.sleep(60)
PY
  LISTEN_PID=$!
  for _ in $(seq 1 50); do
    [[ -s "$portfile" ]] && break
    sleep 0.05
  done
  port="$(cat "$portfile")"
  [[ "$port" =~ ^[0-9]+$ ]]

  run "$PORTS_SH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$port"* ]]
  rm -f "$portfile"
}

@test "ports errors when filtered port is not listening" {
  # High ports unlikely to be bound; try a few.
  local p
  for p in 58431 58432 58433; do
    run "$PORTS_SH" "$p"
    if [[ "$status" -ne 0 ]]; then
      [[ "$output" == *"nothing listening"* ]]
      return 0
    fi
  done
  false
}

@test "ports errors on non-numeric PORT" {
  run "$PORTS_SH" abc
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "ports errors when ss is unavailable" {
  run env PATH="/does/not/exist" /bin/bash "$PORTS_SH"
  [ "$status" -ne 0 ]
  [[ "$output" == *"ss not found"* ]]
}
