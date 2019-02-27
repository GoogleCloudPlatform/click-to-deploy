#!/bin/bash
#
# Copyright 2018 Google LLC
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

source "$(dirname "${0}")/test_util.sh"

declare -r VM_CONFIG_SCRIPT_DIR="/opt/c2d/scripts"
declare -r REGEX="^[0-9]{2}-[0-9a-z]+(-[0-9a-z]+)*$"
declare -i FAILURE_CNT=0
declare -i INDEX=0

start_test_msg "Are c2d startup scripts OK"

shopt -s nullglob
for script in ${VM_CONFIG_SCRIPT_DIR}/*; do
  filename="$(basename "${script}")"

  if [[ ! "${filename}" =~ ${REGEX} ]]; then
    echo "* [${filename}]: The script has an incorrect name. ${REGEX}." && (( FAILURE_CNT+=1 ))
  fi

  if [[ ! "$(printf "%02d" "${INDEX}")" == "$(echo "${filename}" | awk -F'-' '{ print $1 }')" ]]; then
    echo "* [${filename}]: Scripts should have contiguous indices: 000, 001, 002, etc (use c2d-startup-script resource)." && (( FAILURE_CNT+=1 ))
  fi

  if [[ ! -f "${script}" ]]; then
    echo "* [${filename}]: The script must be a file." && (( FAILURE_CNT+=1 ))
  fi

  if [[ ! -x "${script}" ]]; then
    echo "* [${filename}]: The script must be executable." && (( FAILURE_CNT+=1 ))
  fi

  (( INDEX+=1 ))
done

if (( ${FAILURE_CNT} > 0 )); then
  failure
else
  success
fi
