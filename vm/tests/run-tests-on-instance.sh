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

# VARIABLES are come from run-tests.sh as export variables
for var in PACKER_SSH_USERNAME SOLUTION_NAME; do
  if ! [[ -v "${var}" ]]; then
    echo "${var} env variable is required"
    exit 1
  fi
done

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${dir}"

if [[ -d "common" ]]; then
  cp -ar common/*_test.sh .
fi

declare -i success_cnt=0
declare -i failure_cnt=0
declare -i warning_cnt=0
declare -i lcstatus=0

declare -a failed=()

for file in *_test.sh; do
  sudo -s PACKER_SSH_USERNAME="${PACKER_SSH_USERNAME}" SOLUTION_NAME="${SOLUTION_NAME}" bash "./${file}"
  declare -i lcstatus=$?
  case "${lcstatus}" in
    0)
      ((success_cnt+=1))
    ;;
    1)
      ((failure_cnt+=1))
      failed+=(${file})
    ;;
    2)
      ((warning_cnt+=1))
    ;;
    *)
      ((failure_cnt+=1))
    ;;
  esac
done

echo "C2D tests results: SUCCESSES=${success_cnt} FAILURES=${failure_cnt} WARNINGS=${warning_cnt}"
if [[ "${#failed[@]}" -ne 0 ]]; then
  echo
  echo "FAILED TESTS:"
  for key in "${!failed[@]}"; do
    echo "${failed[$key]}"
  done
  echo
fi

exit ${failure_cnt}
