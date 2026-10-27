# bash completion for retry
_jobash_retry() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD >= 3 )); then
    COMPREPLY=( $(compgen -c -- "$cur") )
  fi
}
complete -F _jobash_retry retry
