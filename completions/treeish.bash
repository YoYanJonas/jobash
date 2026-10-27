# bash completion for treeish
_jobash_treeish() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -d -- "$cur") )
  fi
}
complete -o filenames -F _jobash_treeish treeish
