#!/bin/bash

set -euo pipefail

function watch_build() {
  local -r solution="$1"
  local -r build_id="$2"

  local build_status=""
  local -a args=(
    "${build_id}"
    --format
    "value(status)"
  )

  if [[ "${solution}" == k8s* ]]; then
    args+=(
      --region
      us-central1
    )
  fi

  while true; do
    build_status="$(gcloud builds describe "${args[@]}")"

    case "${build_status}" in
      SUCCESS)
      break
      ;;
      WORKING|QUEUED)
      sleep 60
      ;;
      FAILURE|CANCELLED)
      gcloud builds log "${build_id}"
      exit 1
      ;;
      *)
      echo "Unrecognized status: ${build_status}"
      gcloud builds log "${build_id}"
      exit 1
      ;;
    esac
  done
}

function trigger_build() {
  local -r solution="$1"
  local -r app_type="$2"

  # Default args to trigger a build
  local -a args=(
    --substitutions
    "_SOLUTION_NAME=${solution}"
    --timeout
    3600s
    --async
    --config
    "cloudbuild-${app_type}.yaml"
  )

  # For K8s solutions, triggers the build in a specific region
  if [[ "${app_type}" == "k8s" ]]; then
    args+=(
      --region
      "us-central1"
    )
  fi

  gcloud builds submit . "${args[@]}" \
    | awk '/QUEUED/ { print $1 }'
}

# Rename target branch to local, fetch master and identify solution changes
git branch -m "local"
git fetch origin master
git show-ref

git diff --name-only "local" "origin/master" \
  | grep -P -o "^([a-zA-Z0-9._-]+)\/([a-zA-Z0-9._-]+)\/" \
  | uniq \
  | tee changes

declare -A builds=()

# Trigger all possible solution changes
while IFS="/" read -r app_type solution; do
  solution_key="${app_type}/${solution}"

  if [[ "${app_type}" == "docker" || "${app_type}" == "k8s" ]]; then
    # Trigger the build and enqueues the build_id
    echo "Triggering build for ${app_type}/${solution}..."
    solution_build_id="$(trigger_build "${solution}" "${app_type}")"
    builds["${solution_key}"]="${solution_build_id}"
  else
    echo "Skipping: ${app_type}/${solution}."
  fi
done < changes

# Watch all created builds
for solution in "${!builds[@]}"; do
  build_id="${builds[$solution]}"
  echo "Watching build ${build_id} for: ${solution}..."
  watch_build "${solution}" "${build_id}"
done

echo "All completed."
