#!/bin/bash

declare opt_interval_seconds="20"
declare opt_max_retries="10"

function parse_options() {
  while [[ "$#" -ne 0 ]]; do
    case "$1" in
      --interval)
        opt_interval_seconds="$2"
        shift 2
        ;;
      --max_retries)
        opt_max_retries="$2"
        shift 2
        ;;
      *)
        echo >&2 "$1 is not a valid option."
        exit 1
        ;;
    esac
  done
}

function request_with_retry() {
  local -r endpoint="$1"
  local -r max_retries="$2"
  local -r interval_seconds="$3"
  local retries=0

  while [[ "${retries}" -ne "${max_retries}" ]]; do
    echo >&2 "Requesting URL: ${endpoint}"
    echo >&2 "- Retries: ${retries}"

    (( retries=retries+1 ))

    tmp_response="$(mktemp)"
    status_code="$(curl -s -w "%{http_code}" -o "${tmp_response}" "${endpoint}" 2>&1)"

    echo >&2 "- Status Code: ${status_code}"

    if [[ "${status_code}" -ne 200 ]]; then
      if [[ "${retries}" -eq "${max_retries}" ]]; then
        echo "-> Max retries (${max_retries})reached."
        exit 1
      else
        echo >&2 "- Request failed. Next check in ${interval_seconds} seconds..."
        sleep "${interval_seconds}"
      fi
    else
      echo >&2 "-> Success response."
      cat "${tmp_response}"
      exit 0
    fi
  done
}

declare -r resource="$1"
shift 1
parse_options "$@"

declare -r response="$(request_with_retry "http://localhost/-${resource}" "${opt_max_retries}" "${opt_interval_seconds}")"
if [[ "$?" -ne 0 ]]; then
  exit 1
fi
echo "${response}"
