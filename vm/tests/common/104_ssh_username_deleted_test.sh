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

# This test checks if temporary user was deleted
# Remember: "Block project-wide SSH keys" has to be enabled!
start_test_msg "Is ssh_username (${PACKER_SSH_USERNAME}) deleted"
# IF /etc/passwd contains $SSH_USERNAME user
if grep -q "${PACKER_SSH_USERNAME}" /etc/passwd; then
    failure
fi

# Loads config.
if [[ -f "./config/${SOLUTION_NAME}" ]]; then
  . "./config/${SOLUTION_NAME}"
fi

# Verifies that unexpected user directories don't exist.
homedir="/home/"
if [[ -v ssh_username_deleted_allowed_users ]]; then
  directories=$(find ${homedir} -mindepth 1 -maxdepth 1 | grep -c -v "^${homedir}\(${ssh_username_deleted_allowed_users}\)$")
else
  directories=$(find ${homedir} -mindepth 1 -maxdepth 1 | wc -l)
fi
if [[ "${directories}" -eq 1 ]]; then
  success
else
  echo "${homedir}"
  failure
fi
