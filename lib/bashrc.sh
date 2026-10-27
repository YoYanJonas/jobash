#!/usr/bin/env bash
# Manage the # >>> JOBASH / # <<< JOBASH block in a bashrc file.
# shellcheck shell=bash

JOBASH_BASHRC_BEGIN='# >>> JOBASH'
JOBASH_BASHRC_END='# <<< JOBASH'

jobash_bashrc_block() {
  local jobash_home="$1"
  cat <<EOF
$JOBASH_BASHRC_BEGIN
export JOBASH_HOME="$jobash_home"
export PATH="\$JOBASH_HOME/bin:\$PATH"
if [[ -d "\$JOBASH_HOME/shell" ]]; then
  for _jobash_shell in "\$JOBASH_HOME/shell"/*.sh; do
    [[ -f "\$_jobash_shell" ]] && . "\$_jobash_shell"
  done
  unset _jobash_shell
fi
$JOBASH_BASHRC_END
EOF
}

# Write managed block into bashrc (create file if missing). Idempotent.
jobash_bashrc_upsert() {
  local bashrc="$1" jobash_home="$2"
  local tmp dir

  dir="$(dirname "$bashrc")"
  mkdir -p "$dir"
  [[ -f "$bashrc" ]] || : >"$bashrc"

  tmp="$(mktemp)"
  jobash_bashrc_strip "$bashrc" >"$tmp"
  # Ensure trailing newline before appending block
  if [[ -s "$tmp" ]] && [[ "$(tail -c 1 "$tmp" | wc -l)" -eq 0 ]]; then
    printf '\n' >>"$tmp"
  fi
  if [[ -s "$tmp" ]]; then
    printf '\n' >>"$tmp"
  fi
  jobash_bashrc_block "$jobash_home" >>"$tmp"
  mv "$tmp" "$bashrc"
}

# Remove managed block; leave other content.
jobash_bashrc_remove() {
  local bashrc="$1"
  local tmp

  [[ -f "$bashrc" ]] || return 0
  tmp="$(mktemp)"
  jobash_bashrc_strip "$bashrc" >"$tmp"
  mv "$tmp" "$bashrc"
}

# Print bashrc with JOBASH block removed.
jobash_bashrc_strip() {
  local bashrc="$1"
  local in_block=0 line

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$JOBASH_BASHRC_BEGIN" ]]; then
      in_block=1
      continue
    fi
    if [[ "$in_block" -eq 1 ]]; then
      if [[ "$line" == "$JOBASH_BASHRC_END" ]]; then
        in_block=0
      fi
      continue
    fi
    printf '%s\n' "$line"
  done <"$bashrc"
}

jobash_bashrc_has_block() {
  local bashrc="$1"
  [[ -f "$bashrc" ]] || return 1
  grep -qxF "$JOBASH_BASHRC_BEGIN" "$bashrc"
}
