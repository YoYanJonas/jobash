# bash completion for human
_jobash_human() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W '-b -s' -- "$cur") )
  fi
}
complete -F _jobash_human human
