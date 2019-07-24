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
# The test fails if files exist in /var/cache/apt other than:
# - /var/cache/apt/archives
# - /var/cache/apt/archives/lock
# - /var/cache/apt/archives/partial

set -eu

source "$(dirname "${0}")/test_util.sh"

if \
  find /var/cache/apt/ -mindepth 1 \
    ! -path /var/cache/apt/archives \
    ! -path /var/cache/apt/archives/lock \
    ! -path /var/cache/apt/archives/partial \
    -exec false {} +; then
  success
else
  failure
fi
