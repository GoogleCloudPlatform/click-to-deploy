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

# Retry on error using exponential backoff.
# 5 tries. Backoff: 10, 20, 40, 80 seconds.
retry_with_backoff(){
  local cmds=("$@")
  local backoff=10
  while ! "${cmds[@]}" 2>&1; do
    if (( "${backoff}" < 100)); then
      echo "Error: command failed: ${cmds[*]}" >> /dev/stderr
      echo "Backoff and retry in $backoff seconds." >> /dev/stderr
      sleep ${backoff}
      backoff=$(( backoff * 2 ))
    else
      # Fail installation.
      # Return > 0, so that Launcher communicates the failure to customers.
      echo "Command failed. Terminating installation." >> /dev/stderr
      exit 1
    fi
  done
}
