# bash completion for watchfile
_jobash_watchfile() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -f -- "$cur") )
    return
  fi
  COMPREPLY=( $(compgen -c -- "$cur") )
}
complete -o filenames -F _jobash_watchfile watchfile
