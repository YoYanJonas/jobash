#!/usr/bin/env bats

load test_helper

setup() {
  load_jobash_libs
}

@test "discover finds count feature" {
  jobash_features_discover "$REPO_ROOT"
  [ "${#JOBASH_FEATURE_IDS[@]}" -ge 1 ]
  local found=0 id
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    if [[ "$id" == "count" ]]; then
      found=1
      break
    fi
  done
  [ "$found" -eq 1 ]
}

@test "count meta.conf has required keys" {
  local meta="$REPO_ROOT/features/count/meta.conf"
  [ "$(jobash_feature_meta_get "$meta" id)" = "count" ]
  [ "$(jobash_feature_meta_get "$meta" bin)" = "count" ]
  [ "$(jobash_feature_meta_get "$meta" script)" = "count.sh" ]
}

@test "count feature validates" {
  jobash_feature_validate "$REPO_ROOT" count
}

@test "discover finds mktempdir feature" {
  jobash_features_discover "$REPO_ROOT"
  local found=0 id
  for id in "${JOBASH_FEATURE_IDS[@]}"; do
    [[ "$id" == "mktempdir" ]] && found=1
  done
  [ "$found" -eq 1 ]
}

@test "mktempdir shell feature validates" {
  jobash_feature_validate "$REPO_ROOT" mktempdir
  [ "$(jobash_feature_type "$REPO_ROOT/features/mktempdir/meta.conf")" = "shell" ]
}

@test "discover does not leak IFS" {
  local before after
  before="$IFS"
  jobash_features_discover "$REPO_ROOT"
  after="$IFS"
  [ "$before" = "$after" ]
}

@test "split_selection breaks comma-separated numbers" {
  jobash_split_selection "31,29"
  [ "${#JOBASH_TOKENS[@]}" -eq 2 ]
  [ "${JOBASH_TOKENS[0]}" = "31" ]
  [ "${JOBASH_TOKENS[1]}" = "29" ]
}
