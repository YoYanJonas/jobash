#!/usr/bin/env bash
# Copy feature binaries / shell snippets into JOBASH_HOME and wire bashrc.
# shellcheck shell=bash

jobash_install_ensure_prefix() {
  local prefix="$1"
  mkdir -p "$prefix/bin" "$prefix/shell" "$prefix/completions"
}

jobash_install_completion() {
  local root="$1" prefix="$2" id="$3"
  local src dest

  src="$root/completions/${id}.bash"
  [[ -f "$src" ]] || return 0
  jobash_install_ensure_prefix "$prefix"
  dest="$prefix/completions/${id}.bash"
  cp "$src" "$dest"
  jobash_info "installed completion $id -> $dest"
}

jobash_install_feature() {
  local root="$1" prefix="$2" id="$3"
  local meta ftype script_name bin_name src dest

  jobash_feature_validate "$root" "$id"
  meta="$(jobash_feature_meta_path "$root" "$id")"
  ftype="$(jobash_feature_type "$meta")"
  jobash_install_ensure_prefix "$prefix"

  case "$ftype" in
    bin)
      script_name="$(jobash_feature_meta_get "$meta" script)"
      bin_name="$(jobash_feature_meta_get "$meta" bin)"
      src="$(jobash_feature_dir "$root" "$id")/$script_name"
      dest="$prefix/bin/$bin_name"
      if [[ -e "$dest" ]]; then
        jobash_info "skip $id (already installed: $dest)"
        jobash_install_completion "$root" "$prefix" "$id"
        return 0
      fi
      cp "$src" "$dest"
      chmod +x "$dest"
      jobash_info "installed $bin_name -> $dest"
      ;;
    shell)
      src="$(jobash_feature_dir "$root" "$id")/shell.sh"
      dest="$prefix/shell/${id}.sh"
      if [[ -e "$dest" ]]; then
        jobash_info "skip $id (already installed: $dest)"
        jobash_install_completion "$root" "$prefix" "$id"
        return 0
      fi
      cp "$src" "$dest"
      jobash_info "installed shell $id -> $dest"
      ;;
  esac
  jobash_install_completion "$root" "$prefix" "$id"
}

jobash_install_features() {
  local root="$1" prefix="$2" bashrc="$3"
  shift 3
  local id

  ((${#@} > 0)) || jobash_die "no features selected"
  for id in "$@"; do
    jobash_install_feature "$root" "$prefix" "$id"
  done
  jobash_install_core "$root" "$prefix"
  jobash_bashrc_upsert "$bashrc" "$prefix"
  jobash_info "updated $bashrc"
  jobash_bashrc_reload "$bashrc"
}

# Print install destination path for a feature (bin or shell snippet).
jobash_feature_dest() {
  local root="$1" prefix="$2" id="$3"
  local meta ftype bin_name

  meta="$(jobash_feature_meta_path "$root" "$id")"
  ftype="$(jobash_feature_type "$meta")"
  case "$ftype" in
    bin)
      bin_name="$(jobash_feature_meta_get "$meta" bin)" || return 1
      printf '%s\n' "$prefix/bin/$bin_name"
      ;;
    shell)
      printf '%s\n' "$prefix/shell/${id}.sh"
      ;;
    *)
      return 1
      ;;
  esac
}

jobash_feature_is_installed() {
  local root="$1" prefix="$2" id="$3"
  local dest
  dest="$(jobash_feature_dest "$root" "$prefix" "$id")" || return 1
  [[ -e "$dest" ]]
}

# Populate JOBASH_INSTALLED_IDS with feature ids present under prefix.
jobash_installed_discover() {
  local root="$1" prefix="$2"
  local id
  JOBASH_INSTALLED_IDS=()
  jobash_features_discover "$root"
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    if jobash_feature_is_installed "$root" "$prefix" "$id"; then
      JOBASH_INSTALLED_IDS+=("$id")
    fi
  done
}

jobash_uninstall_feature() {
  local root="$1" prefix="$2" id="$3"
  local dest comp
  dest="$(jobash_feature_dest "$root" "$prefix" "$id")" || return 0
  if [[ -e "$dest" ]]; then
    rm -f "$dest"
    jobash_info "removed $dest"
  else
    jobash_info "skip $id (not installed)"
  fi
  comp="$prefix/completions/${id}.bash"
  if [[ -e "$comp" ]]; then
    rm -f "$comp"
    jobash_info "removed $comp"
  fi
}

# Remove selected features. If none remain installed, drop bashrc block and prefix.
jobash_uninstall_features() {
  local root="$1" prefix="$2" bashrc="$3"
  shift 3
  local id

  ((${#@} > 0)) || jobash_die "no features selected"
  for id in "$@"; do
    jobash_feature_exists "$root" "$id" || jobash_die "unknown feature: $id"
    jobash_uninstall_feature "$root" "$prefix" "$id"
  done

  jobash_installed_discover "$root" "$prefix"
  if ((${#JOBASH_INSTALLED_IDS[@]} == 0)); then
    jobash_uninstall_wipe_prefix "$prefix" "$bashrc"
  fi
}

# Full cleanup: every known feature artifact, bashrc block, and prefix dir.
jobash_uninstall() {
  local root="$1" prefix="$2" bashrc="$3"
  local id

  jobash_features_discover "$root"
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    jobash_uninstall_feature "$root" "$prefix" "$id"
  done
  jobash_uninstall_wipe_prefix "$prefix" "$bashrc"
}

jobash_uninstall_wipe_prefix() {
  local prefix="$1" bashrc="$2"

  jobash_bashrc_remove "$bashrc"
  jobash_info "removed JOBASH block from $bashrc"
  if [[ -d "$prefix" ]]; then
    rm -rf "$prefix"
    jobash_info "removed $prefix"
  fi
}

jobash_run_example() {
  local root="$1" id="$2"
  local example

  jobash_feature_validate "$root" "$id"
  example="$(jobash_feature_dir "$root" "$id")/example.sh"
  [[ -x "$example" ]] || chmod +x "$example"
  bash "$example"
}
