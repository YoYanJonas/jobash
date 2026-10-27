#!/usr/bin/env bash
# qr: render a QR code in the terminal
# Usage: qr STRING
set -euo pipefail

usage() {
  echo "Usage: qr STRING" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
text="$1"
[[ -n "$text" ]] || usage

if command -v qrencode >/dev/null 2>&1; then
  qrencode -t ANSIUTF8 -- "$text"
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 - "$text" <<'PY'
import sys
try:
    import qrcode
except ImportError:
    sys.exit(2)
data = sys.argv[1]
q = qrcode.QRCode(border=1)
q.add_data(data)
q.make(fit=True)
q.print_ascii(invert=True)
PY
  then
    exit 0
  elif [[ $? -eq 2 ]]; then
    :
  else
    echo "qr: failed to render with python qrcode" >&2
    exit 1
  fi
fi

echo "qr: need qrencode or python3+qrcode package" >&2
exit 1
