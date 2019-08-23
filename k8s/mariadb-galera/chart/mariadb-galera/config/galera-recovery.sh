#!/bin/bash
#
# Copyright 2019 Google LLC
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
# Recovery procedure uses wsrep_recover option to find position and provide
# wsrep_start_position option to mysqld:
# https://mariadb.com/kb/en/library/galera-cluster-system-variables/#wsrep_recover

set -eu

USER=mysql
EUID=$(id -u)
LOG_FILE=$(mktemp /tmp/wsrep_recovery.XXXXXX)
START_POS=''
START_POS_OPT=''

log() {
    local MSG="galera-recovery.sh: $@"
    # Print all messages to stderr as we reserve stdout for printing
    # --wsrep-start-position=XXXX.
    echo "${MSG}" >&2
}

finish() {
    rm -f "${LOG_FILE}"
}

trap finish EXIT

wsrep_recover_position() {
    mysqld --user=${USER} --wsrep-recover --log-error="${LOG_FILE}"
    if [[ $? -ne 0 ]]; then
        # Something went wrong, let us also print the error log so that it
        # shows up in systemctl status output as a hint to the user.
        log "Failed to start mysqld for wsrep recovery: '$(cat ${LOG_FILE})'"
        exit 1
    fi

    START_POS=$(sed -n 's/.*WSREP: Recovered position:\s*//p' ${LOG_FILE})

    if [[ -z ${START_POS} ]]; then
        SKIPPED="$(grep WSREP ${LOG_FILE} | grep 'skipping position recovery')"
        if [[ -z "${SKIPPED}" ]]; then
            log "=================================================="
            log "WSREP: Failed to recover position: '$(cat ${LOG_FILE})'"
            log "=================================================="
            exit 1
        else
            log "WSREP: Position recovery skipped."
        fi

    else
        log "Found WSREP position: ${START_POS}"

        # Force start even if some latest TX are lost before a crash
        # otherwise container just cannot start in K8s StatefulSet configuration
        sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat

        START_POS_OPT="--wsrep_start_position=${START_POS}"
    fi
}

if [[ -n "${LOG_FILE}" -a -f "${LOG_FILE}" ]]; then
    [[ "${EUID}" = "0" ]] && chown ${USER} ${LOG_FILE}
    chmod 600 ${LOG_FILE}
else
    log "WSREP: mktemp failed"
fi

if [[ -f /var/lib/mysql/ibdata1 ]]; then
    log "Attempting to recover GTID position..."
    wsrep_recover_position
else
    log "No ibdata1 found, starting a fresh node..."
fi

echo "${START_POS_OPT}"
