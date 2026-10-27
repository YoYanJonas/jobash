# bash completion for biggest
_jobash_biggest() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -d -- "$cur") )
  fi
}
complete -o filenames -F _jobash_biggest biggest
