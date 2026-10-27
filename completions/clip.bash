# bash completion for clip
_jobash_clip() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -o filenames -F _jobash_clip clip
