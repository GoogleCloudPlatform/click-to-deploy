#!/bin/bash

function watch_build() {
  local -r build_id="$1"
  local build_status=""

  while true; do
    build_status="$(gcloud builds list \
                      --filter="ID:${build_id}" \
                      --format="value(STATUS)")"

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

# Compare local master to remote master (GCB clones the target branch as master)
git fetch origin master
git diff --name-only "master" $(git merge-base "origin/master" "refs/remotes/origin/master") \
  | grep -P -o "^(\w+)\/(\w+)" \
  | uniq \
  | tee changes

declare -A builds=()

# Trigger all possible solution changes
while IFS="/" read -r app_type solution; do
  solution_key="${app_type}/${solution}"

  if [[ "${app_type}" == "docker" || "${app_type}" == "k8s" ]]; then
    echo "Triggering build for ${solution_key}..."
    solution_build_id="$(gcloud builds submit . \
                          --substitutions "_SOLUTION_NAME=${solution}" \
                          --timeout 3600s \
                          --async \
                          --config cloudbuild-${app_type}.yaml | awk '/QUEUED/ { print $1 }')"

    builds["${solution_key}"]="${solution_build_id}"
  else
    echo "Skipping: ${app_type}/${solution}."
  fi
done < changes

# Watch all created builds
echo "${builds[@]}"

for solution in "${!builds[@]}"; do
  build_id="${builds[$solution]}"
  echo "Watching build ${build_id} for: ${solution}..."
  watch_build "${build_id}"
done

echo "All completed."
