#!/bin/bash -eu
#
# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get a metadata value from the metadata server.
declare -r MDS_PREFIX=http://metadata.google.internal/computeMetadata/v1

function print_metadata_value() {
  local readonly tmpfile=$(mktemp)
  http_code=$(curl -f "${1}" -H "Metadata-Flavor: Google" -w "%{http_code}" \
    -s -o "${tmpfile}" 2>/dev/null)
  local readonly return_code=$?
  # If the command completed successfully, print the metadata value to stdout.
  if [[ "${return_code}" == 0 && ${http_code} == 200 ]]; then
    cat "${tmpfile}"
  fi
  rm -f "${tmpfile}"
  return "${return_code}"
}

function print_metadata_value_if_exists() {
  local return_code=1
  local readonly url="${1}"
  print_metadata_value "${url}"
  return_code=$?
  return "${return_code}"
}

function get_metadata_value() {
  local readonly metadata_path="${1}"
  # Print the instance metadata value.
  print_metadata_value_if_exists "${MDS_PREFIX}/${metadata_path}"
  return_code=$?
  return "${return_code}"
}

function get_metadata_value_with_retries() {
  local readonly VARNAME="${1}"
  local readonly RETRIES=100
  local return_code=1  # General error code.
  for ((count=0; count <= $RETRIES; count++)); do
    get_metadata_value "${VARNAME}"
    return_code=$?
    case $return_code in
      # No error.  We're done.
      0) exit "${return_code}";;
      # Failed to resolve host or connect to host.  Retry.
      6|7) sleep 0.3; continue;;
      # A genuine error. Stop here.
      *) return "${return_code}";;
    esac
  done
  # Exit with the last return code we got.
  return "${return_code}"
}

function get_metadata() {
  get_metadata_value_with_retries "${1}"
}
