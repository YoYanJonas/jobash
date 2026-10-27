# gitroot: cd to the nearest git repository root
gitroot() {
  local root
  if ! command -v git >/dev/null 2>&1; then
    echo "gitroot: git not found" >&2
    return 1
  fi
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "gitroot: not inside a git repository" >&2
    return 1
  }
  cd -- "$root" || return 1
  pwd
}
