#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KILLPORT="$ROOT/killport.sh"

python3 - "$KILLPORT" <<'PY'
import socket, subprocess, sys, time, os

killport = sys.argv[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 0))
port = s.getsockname()[1]
s.listen(1)
print(f"$ killport {port}")
print(subprocess.check_output([killport, str(port)], text=True), end="")
time.sleep(0.2)
s.close()
PY
