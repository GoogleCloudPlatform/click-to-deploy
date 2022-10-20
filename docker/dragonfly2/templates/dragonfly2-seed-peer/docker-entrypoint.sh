#!/bin/bash

function replace_vars(){

    local SOURCE_FILE="/etc/dragonfly/dfget.yaml"
    local VARS="\$DRAGONFLY_MANAGER_ADDR \$DRAGONFLY_SCHEDULER_ADDR \$DRAGONFLY_SEED_PEER_ADDR"
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

/opt/dragonfly/bin/dfget daemon --console

