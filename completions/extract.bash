# bash completion for extract
_jobash_extract() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -o filenames -F _jobash_extract extract
