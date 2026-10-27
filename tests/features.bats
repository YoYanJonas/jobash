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
