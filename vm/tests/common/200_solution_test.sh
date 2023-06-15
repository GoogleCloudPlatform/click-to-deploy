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
# This test execute Serverspec tests. The test should be run after other tests
# because it installs software on the system.

set -eu

source "$(dirname "${0}")/test_util.sh"

echo -e "\n=== TEST $(basename "$0"): runs tests for ${SOLUTION_NAME} ==="

if [[ ! -d "solutions/spec/${SOLUTION_NAME}" ]]; then
  warning_msg "There are no tests for ${SOLUTION_NAME}"
  exit 2
fi

apt-get -y install ruby
gem install net-ssh -v 6.1.0
gem install serverspec rake

cd solutions/
rake "spec:${SOLUTION_NAME}" && success || failure
