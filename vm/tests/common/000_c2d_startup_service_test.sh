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

readonly VM_CONFIG_SCRIPT_DIR="/opt/c2d/scripts"

# A single instance (to run tests) is created without metadata properties items.
# These properties are needed to run startup scripts successfully.
# Also, the created instance has property 'google-c2d-startup-enable=0',
# that should disabled startup scripts.
# This test checks if c2d startup scripts are really disabled.
start_test_msg "Is google-c2d-startup.service disabled"
{
  systemctl status google-c2d-startup.service |
  grep -q 'Google C2D startup config is disabled.'
} && success || failure

# This test checks if startup-script exists
start_test_msg "Does ${VM_CONFIG_SCRIPT_DIR} exist"
if [[ -d "${VM_CONFIG_SCRIPT_DIR}" ]]; then
  success
else
  failure
fi
