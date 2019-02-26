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
#
# This test verifies that expected bash shebang lines and headers
# statements are in all files in /opt/c2d/scripts.

set -eu

source "$(dirname "${0}")/test_util.sh"

declare -r VM_CONFIG_SCRIPT_DIR="/opt/c2d/scripts"
declare -r YEAR="$(date +%Y)"
declare -i FAILURE_CNT=0

function print_shebang() {
  echo "#!/bin/bash -eu"
}

# NOTE: Year in the license has to be replaced to ${YEAR} variable.
function print_license() {
  cat << EOF
# Copyright ${YEAR} Google Inc.
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
EOF
}

function print_pattern() {
  echo -e "$(print_shebang)\n#\n$(print_license)"
}

function print_tips() {
  cat << EOF
VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
VVV below is the pattern that you have to follow VVV
VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
$(print_pattern)

<your code>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^ above is the pattern that you have to follow ^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EOF
}

echo "Please follow the right pattern in these files:"

pattern_lines_count="$(print_pattern | wc -l)"

shopt -s nullglob
for script in ${VM_CONFIG_SCRIPT_DIR}/*; do
  # Get the begin script lines, count the lines from $(print_pattern) function.
  script_begin="$(sed -n "1,${pattern_lines_count}p" "${script}")"
  # Change the year to the current.
  script_content="$(echo "${script_begin}" | sed "s/Copyright 20[0-9][0-9]/Copyright ${YEAR}/")"

  # Compare pattern with the script.
  if [[ "$(print_pattern)" != "${script_content}" ]]; then
    echo "(*) ${script}"
    (( FAILURE_CNT+=1 ))
  fi
done

if (( ${FAILURE_CNT} > 0 )); then
  echo -e "\n$(print_tips)"
  failure
else
  success
fi
