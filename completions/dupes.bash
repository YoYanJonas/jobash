# bash completion for dupes
_jobash_dupes() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -o filenames -F _jobash_dupes dupes
