# bash completion for whichall
_jobash_whichall() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -c -- "$cur") )
}
complete -F _jobash_whichall whichall
