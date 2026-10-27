# bash completion for count
_jobash_count() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W '-f -d' -- "$cur") )
    return
  fi
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -F _jobash_count count
