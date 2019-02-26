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
# These tests check if logs were cleaned.

set -eu

source "$(dirname "${0}")/test_util.sh"

# Looks for VM prefix word (used during building).
declare -r vm_prefix=click-to-deploy
start_test_msg "Looking for '${vm_prefix}' word inside /var/log/ dir"
egrep -q -R "${vm_prefix}-.*" /var/log/ && \
  failure || success

# Compare VM boot time with time of files modification inside /var/log/ dir.
start_test_msg "Comparing VM boot time with time of files modification inside /var/log/ dir"
if \
  find /var/log/ -type f \
    ! -newermt "$( uptime -s )" \
    -exec false {} +; then
  success
else
  warning
fi
