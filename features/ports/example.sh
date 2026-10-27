#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTS="$ROOT/ports.sh"

python3 - "$PORTS" <<'PY'
import socket, subprocess, sys, time

ports_sh = sys.argv[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 0))
port = s.getsockname()[1]
s.listen(1)
print(f"$ ports {port}")
out = subprocess.check_output([ports_sh, str(port)], text=True)
print(out, end="")
s.close()
PY
