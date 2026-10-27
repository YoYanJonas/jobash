# bash completion for jsonpp
_jobash_jsonpp() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -o filenames -F _jobash_jsonpp jsonpp
