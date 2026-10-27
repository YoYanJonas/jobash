# bash completion for fsize
_jobash_fsize() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -o filenames -F _jobash_fsize fsize
