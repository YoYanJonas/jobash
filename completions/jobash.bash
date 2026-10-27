# bash completion for jobash hub
_jobash_hub() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD == 1 )); then
    COMPREPLY=( $(compgen -W 'installed install uninstall docs quit' -- "$cur") )
  fi
}
complete -F _jobash_hub jobash
