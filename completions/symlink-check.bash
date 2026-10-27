# bash completion for symlink-check
_jobash_symlink_check() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -o filenames -F _jobash_symlink_check symlink-check
