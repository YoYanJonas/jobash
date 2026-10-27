# mktempdir: create a temp directory (optional name prefix) and cd into it.
mktempdir() {
  local name="${1:-}" dir
  if [[ -n "$name" ]]; then
    dir="$(mktemp -d "${TMPDIR:-/tmp}/${name}.XXXXXX")"
  else
    dir="$(mktemp -d)"
  fi
  cd "$dir" || return 1
  pwd
}
