# bash completion for pathadd
_jobash_pathadd() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -o filenames -F _jobash_pathadd pathadd
