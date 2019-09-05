#!/bin/bash

set -eu

shopt -s nullglob

# Ensure all required env vars are supplied.
for var in DIRECTORY_NAME CLOUDBUILD_NAME PROJECT; do
  if ! [[ -v "${var}" ]]; then
    echo "${var} env variable is required"
    exit 1
  fi
done

function trigger_exist {
  local -r solution=$1

  gcloud alpha builds triggers list --project="${PROJECT}" --format json \
    | jq -e --arg filename "${CLOUDBUILD_NAME}" --arg solution "${solution}" \
    '.[] | select(.filename == $filename) | select(.substitutions._SOLUTION_NAME == $solution)'
}

function main {
  declare -i failure_cnt=0

  for solution in ${DIRECTORY_NAME}/*; do
    if [[ -d ${solution} ]]; then
      solution="${solution%/}"     # strip trailing slash
      solution="${solution##*/}"   # strip path and leading slash

      set +e
      trigger_exist "${solution}"
      local -i status_code=$?
      set -e

      if [[ ${status_code} -gt 0 ]]; then
        echo "[${solution}] FAIL"
        (( failure_cnt+=1 ))
      else
        echo "[${solution}] PASS"
      fi
    fi
  done

  return ${failure_cnt}
}

main "$@"
