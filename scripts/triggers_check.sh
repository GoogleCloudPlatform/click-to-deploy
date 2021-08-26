#!/bin/bash
#
# Copyright 2019 Google LLC
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

set -eu

shopt -s nullglob

# Ensure all required env vars are supplied.
for var in DIRECTORY_NAME CLOUDBUILD_NAME PROJECT; do
  if ! [[ -v "${var}" ]]; then
    echo "${var} env variable is required"
    exit 1
  fi
done

function generate_trigger_name() {
  local -r solution="$1"
  local solution_type_name=""

  case "${DIRECTORY_NAME}" in
    docker)
      solution_type_name="Docker"
      ;;
    k8s)
      solution_type_name="K8s"
      ;;
    vm*)
      solution_type_name="VM"
      ;;
    *)
      echo "Solution type not supported."
      exit 1
      ;;
  esac

  # Trigger-for-Docker-zookeeper
  echo "Trigger-for-${solution_type_name}-${solution}"
}

function trigger_active {
  local -r solution=$1
  local exit_code=""
  local -r trigger_name="$(generate_trigger_name "${solution}")"

  gcloud alpha builds triggers list --project="${PROJECT}" --format json > /tmp/triggers.json
  jq -e --arg solution "${solution}" --arg triggerName "${trigger_name}" \
    '.[] | select(.name == $triggerName and .substitutions._SOLUTION_NAME == $solution and .disabled != true)' /tmp/triggers.json

  return $?
}

function main {
  local -i failure_cnt=0
  local -a failures=()

  for solution in ${DIRECTORY_NAME}/*; do
    if [[ -d ${solution} ]]; then
      solution="${solution%/}"     # strip trailing slash
      solution="${solution##*/}"   # strip path and leading slash
      echo "${solution}"

      set +e
      trigger_active "${solution}"
      local -i status_code=$?
      set -e

      if [[ ${status_code} -gt 0 ]]; then
        echo "[${solution}] FAIL"
        (( failure_cnt+=1 ))
        failures+=("${solution}")
      else
        echo "[${solution}] PASS"
      fi
    fi
  done

  echo "*************************************************************"
  echo "* Done with ${failure_cnt} failure(s):"

  if [[ "${failure_cnt}" -gt 0 ]]; then
    for failed in "${failures[@]}"; do
        echo "- ${failed}";
    done

    gcloud alpha builds triggers list --project="${PROJECT}" --format json > /tmp/triggers.json
    cat -n /tmp/triggers.json
  fi

  echo "* For more information, see https://github.com/GoogleCloudPlatform/click-to-deploy/blob/master/triggers/README.md"
  echo "*************************************************************"

  return ${failure_cnt}
}

main "$@"
