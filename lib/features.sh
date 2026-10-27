#!/usr/bin/env bash
# Feature discovery and meta.conf parsing.
# shellcheck shell=bash

# Populate JOBASH_FEATURE_IDS (array) with sorted feature ids under features/.
jobash_features_discover() {
  local root="${1:-}"
  local dir meta id
  JOBASH_FEATURE_IDS=()

  [[ -n "$root" ]] || jobash_die "features_discover: repo root required"
  jobash_require_dir "$root/features"

  shopt -s nullglob
  for dir in "$root/features"/*/; do
    meta="${dir}meta.conf"
    [[ -f "$meta" ]] || continue
    id="$(jobash_feature_meta_get "$meta" id)"
    [[ -n "$id" ]] || jobash_die "feature missing id: $meta"
    JOBASH_FEATURE_IDS+=("$id")
  done
  shopt -u nullglob

  if ((${#JOBASH_FEATURE_IDS[@]} > 0)); then
    # shellcheck disable=SC2207
    IFS=$'\n' JOBASH_FEATURE_IDS=($(printf '%s\n' "${JOBASH_FEATURE_IDS[@]}" | sort))
  fi
}

jobash_feature_dir() {
  local root="$1" id="$2"
  printf '%s\n' "$root/features/$id"
}

jobash_feature_meta_path() {
  local root="$1" id="$2"
  printf '%s\n' "$root/features/$id/meta.conf"
}

# Read key=value from meta.conf (first match). Values are trimmed.
jobash_feature_meta_get() {
  local meta="$1" key="$2" line val
  jobash_require_file "$meta"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    if [[ "$line" =~ ^[[:space:]]*${key}=(.*)$ ]]; then
      val="${BASH_REMATCH[1]}"
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"
      printf '%s\n' "$val"
      return 0
    fi
  done <"$meta"
  return 1
}

jobash_feature_validate() {
  local root="$1" id="$2"
  local dir meta script_name script_path bin_name

  dir="$(jobash_feature_dir "$root" "$id")"
  meta="$(jobash_feature_meta_path "$root" "$id")"
  jobash_require_dir "$dir"
  jobash_require_file "$meta"

  script_name="$(jobash_feature_meta_get "$meta" script)" \
    || jobash_die "feature $id: missing script= in meta.conf"
  bin_name="$(jobash_feature_meta_get "$meta" bin)" \
    || jobash_die "feature $id: missing bin= in meta.conf"
  script_path="$dir/$script_name"
  jobash_require_file "$script_path"
  [[ -x "$script_path" ]] || jobash_die "feature $id: not executable: $script_path"
  [[ -f "$dir/example.sh" ]] || jobash_die "feature $id: missing example.sh"
}

jobash_feature_exists() {
  local root="$1" id="$2"
  [[ -f "$(jobash_feature_meta_path "$root" "$id")" ]]
}

jobash_features_require_ids() {
  local root="$1"
  shift
  local id
  for id in "$@"; do
    jobash_feature_exists "$root" "$id" || jobash_die "unknown feature: $id"
    jobash_feature_validate "$root" "$id"
  done
}
