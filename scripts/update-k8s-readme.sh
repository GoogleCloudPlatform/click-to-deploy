#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function get_tags_by_solution() {
  local -r repo="marketplace.gcr.io/google"
  local -r solution="$1"
  local -r tags="$(gcloud container images list-tags \
                    "${repo}/${solution}" \
                      --format json \
                      --limit 1 \
                    | jq -r '.[0].tags | join(",")')"
  echo "${tags}"
}

function update_stable_tag() {
  local -r readme="$1"
  local -r stable_tag="$2"
  local -r search_regex="export TAG=\"([0-9]+)\.([0-9]+)\.([0-9]+)\-.*"

  local -r found_stable_tag="$(grep -E "${search_regex}" "${readme}" \
                               | wc -l)"

  if [[ ! -z "${stable_tag}" && "${found_stable_tag}" -gt 0 ]]; then
    sed -i -E \
      "s/${search_regex}/export TAG=\"${stable_tag}-<BUILD_ID>\"/g" \
      "${readme}"
    echo "true"
    return
  fi
  echo "false"
}

function update_track_tag() {
  local -r readme="$1"
  local -r track_tag="$2"
  local -r search_regex='export TAG=\"([0-9]+)\.([0-9]+)\"'

  found_track_tag="$(grep -E "${search_regex}" "${readme}" \
                      | wc -l)"

  if [[ ! -z "${track_tag}" && "${found_track_tag}" -gt 0 ]]; then
    sed -i -E \
      "s/${search_regex}/export TAG=\"${track_tag}\"/g" \
      "${readme}"
    echo "true"
    return
  fi
  echo "false"
}

declare -r script_path="$(dirname "$0")"
declare -r k8s_path="$(realpath "${script_path}/../k8s/")"

echo >&2 "K8s Path: ${k8s_path}"

# Iterate over all k8s/**/ READMEs
for readme in $(find "${k8s_path}" -maxdepth 2 -mindepth 2 -name README.md); do
  # Extract the solution name from the path
  solution="$(echo "${readme}" | awk -F '/' '{ print $(NF-1) }')"
  tags="$(get_tags_by_solution "${solution}")"

  stable_tag="$(echo "${tags}" | cut -f 2 -d ',' \
                | grep -P -o "\d+\.\d+\.\d+")"
  track_tag="$(echo "${tags}" | cut -f 1 -d ',')"

  echo >&2 "Solution: ${solution}"
  echo >&2 "Stable: ${stable_tag}"
  echo >&2 "Track: ${track_tag}"
  echo >&2 "README: ${readme}"

  if [[ "$(update_stable_tag "${readme}" "${stable_tag}")" == "true" ]]; then
    echo >&2 "Stable tag updated to ${stable_tag}"
  fi

  if [[ "$(update_track_tag "${readme}" "${track_tag}")" == "true" ]]; then
    echo >&2 "Track tag updated to ${track_tag}"
  fi

  echo >&2 "---------"
done

echo >&2 "Finished!"
echo >&2 "---------"
echo >&2 "Please double-check the documentation updates before merging this PR!"
echo >&2 "---------"
