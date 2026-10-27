# bash completion for empty
_jobash_empty() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -o filenames -F _jobash_empty empty
