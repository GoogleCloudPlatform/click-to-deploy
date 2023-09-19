#!/bin/bash

# Copyright 2022 Google LLC
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

function replace_vars(){

    local SOURCE_FILE="/etc/dragonfly/scheduler.yaml"
    local VARS="\$DRAGONFLY_REDIS_HOST \$DRAGONFLY_REDIS_PW \$DRAGONFLY_MANAGER_ADDR"
    local TEMP_OUTPUT

        # Check if source file exists
    if [[ ! -f ${SOURCE_FILE} ]]; then
        echo >&2 "File ${SOURCE_FILE} not found."
        exit 1
    fi

    # Replace variables from temp variable and
    # outputs to the source file
    TEMP_OUTPUT=$(cat ${SOURCE_FILE} | envsubst "${VARS}")
    echo -n "${TEMP_OUTPUT}" > "${SOURCE_FILE}"

    # If it fails, exit with error, otherwise exit with success.
    if [[ "$?" -ne 0 ]]; then
        echo >&2 "Error parsing file."
        exit 1
    fi
}

replace_vars

/opt/dragonfly/bin/scheduler 

