# pathadd: prepend a directory to PATH for the current shell
pathadd() {
  local dir="${1:-}" abs
  if [[ -z "$dir" ]]; then
    echo "Usage: pathadd DIR" >&2
    return 1
  fi
  if [[ ! -d "$dir" ]]; then
    echo "pathadd: not a directory: $dir" >&2
    return 1
  fi
  abs="$(cd -- "$dir" && pwd)"
  case ":$PATH:" in
    *":$abs:"*) ;;
    *) PATH="$abs${PATH:+:$PATH}" ;;
  esac
  export PATH
  printf '%s\n' "$abs"
}
