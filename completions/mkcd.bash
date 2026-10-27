# bash completion for mkcd
_jobash_mkcd() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -o filenames -F _jobash_mkcd mkcd
