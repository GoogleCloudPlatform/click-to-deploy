#!/bin/bash -eu

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

# Utility functions to:
# - Identify whether the instance is a primary or replica.
# - Identify Linux distributions.

readonly REPLICA_FILE="/opt/c2d/is_replica"
readonly REPLICATING_FILE="/opt/c2d/is_replicating"
readonly CENTOS_RELEASE="/etc/centos-release"

is_primary() {
  ! [[ -e "${REPLICA_FILE}" ]]
}

is_replica() {
  [[ -e "${REPLICA_FILE}" ]]
}

is_replicating() {
  [[ -e "${REPLICATING_FILE}" ]]
}

tag_replica() {
  touch "${REPLICA_FILE}"
}

tag_replicating() {
  touch "${REPLICATING_FILE}"
}

is_centos() {
  [[ -e "${CENTOS_RELEASE}" ]]
}

is_debian() {
  ! [[ -e "${CENTOS_RELEASE}" ]]
}
