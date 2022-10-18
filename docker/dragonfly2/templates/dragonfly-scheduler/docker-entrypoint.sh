#!/bin/bash

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
        exit_with_error "Error parsing file."
    fi
}

replace_vars

exec "/opt/dragonfly/bin/scheduler"

