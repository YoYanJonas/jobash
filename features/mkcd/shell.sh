# mkcd: mkdir -p then cd into the path
mkcd() {
  local dir="${1:-}"
  if [[ -z "$dir" ]]; then
    echo "Usage: mkcd DIR" >&2
    return 1
  fi
  mkdir -p -- "$dir" || return 1
  cd -- "$dir" || return 1
  pwd
}
