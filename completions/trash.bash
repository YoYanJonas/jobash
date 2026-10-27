# bash completion for trash
_jobash_trash() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -o filenames -F _jobash_trash trash
