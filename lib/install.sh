#!/usr/bin/env bash
# Copy feature binaries into JOBASH_HOME/bin and wire bashrc.
# shellcheck shell=bash

jobash_install_ensure_prefix() {
  local prefix="$1"
  mkdir -p "$prefix/bin"
}

jobash_install_feature() {
  local root="$1" prefix="$2" id="$3"
  local meta script_name bin_name src dest

  jobash_feature_validate "$root" "$id"
  meta="$(jobash_feature_meta_path "$root" "$id")"
  script_name="$(jobash_feature_meta_get "$meta" script)"
  bin_name="$(jobash_feature_meta_get "$meta" bin)"
  src="$(jobash_feature_dir "$root" "$id")/$script_name"
  dest="$prefix/bin/$bin_name"

  jobash_install_ensure_prefix "$prefix"
  cp "$src" "$dest"
  chmod +x "$dest"
  jobash_info "installed $bin_name -> $dest"
}

jobash_install_features() {
  local root="$1" prefix="$2" bashrc="$3"
  shift 3
  local id

  ((${#@} > 0)) || jobash_die "no features selected"
  for id in "$@"; do
    jobash_install_feature "$root" "$prefix" "$id"
  done
  jobash_bashrc_upsert "$bashrc" "$prefix"
  jobash_info "updated $bashrc"
}

jobash_uninstall() {
  local root="$1" prefix="$2" bashrc="$3"
  local id meta bin_name dest

  jobash_features_discover "$root"
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    meta="$(jobash_feature_meta_path "$root" "$id")"
    bin_name="$(jobash_feature_meta_get "$meta" bin)" || continue
    dest="$prefix/bin/$bin_name"
    if [[ -e "$dest" ]]; then
      rm -f "$dest"
      jobash_info "removed $dest"
    fi
  done
  jobash_bashrc_remove "$bashrc"
  jobash_info "removed JOBASH block from $bashrc"
}

jobash_run_example() {
  local root="$1" id="$2"
  local example

  jobash_feature_validate "$root" "$id"
  example="$(jobash_feature_dir "$root" "$id")/example.sh"
  [[ -x "$example" ]] || chmod +x "$example"
  bash "$example"
}
