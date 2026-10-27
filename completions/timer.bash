# bash completion for timer
_jobash_timer() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -c -- "$cur") )
}
complete -F _jobash_timer timer
