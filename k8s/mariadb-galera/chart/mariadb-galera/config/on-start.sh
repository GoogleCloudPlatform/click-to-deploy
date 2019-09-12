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
# This script receives list of MariaDB Galera Cluster nodes that are
# already up and fills wsrep options in galera configuration file accordingly.

set -eu

GALERA_CONF="${GALERA_CONF:-"/etc/mysql/conf.d/galera.cnf"}"
PEERS=()
DATADIR="/var/lib/mysql"

if ! [[ -f "${GALERA_CONF}" ]]; then
    cp /opt/galera/galera.cnf "${GALERA_CONF}"
fi

function join {
    # Concatenate a list of adresses with IFS delimiter
    local IFS="$1"; shift; echo "$*";
}

# Parse out cluster name by deleting ordinal index from hostname
HOSTNAME=$(hostname)
CLUSTER_NAME=${HOSTNAME%-*}

while read -ra LINE; do
    if [[ "${LINE}" == *"${HOSTNAME}"* ]]; then
        MY_NAME=${LINE}
    else
        PEERS=("${PEERS[@]}" ${LINE})
    fi
done

if [[ "${#PEERS[@]}" = 0 ]]; then
    # should be empty in order to bootstrap new cluster if no peers found
    export WSREP_CLUSTER_ADDRESS=""
else
    # should be filled with other nodes addresses in order to join existing cluster
    export WSREP_CLUSTER_ADDRESS=$(join , "${PEERS[@]}")
fi

# Update galera config file with wsrep options to initialize cluster
sed -i -e "s|^wsrep_node_address[[:space:]]*=.*$|wsrep_node_address=${MY_NAME}|" "${GALERA_CONF}"
sed -i -e "s|^wsrep_cluster_name[[:space:]]*=.*$|wsrep_cluster_name=${CLUSTER_NAME}|" "${GALERA_CONF}"
sed -i -e "s|^wsrep_cluster_address[[:space:]]*=.*$|wsrep_cluster_address=gcomm://${WSREP_CLUSTER_ADDRESS}|" "${GALERA_CONF}"

# Don't need a restart, we're just writing the conf in case there's an
# unexpected restart on the node.

if [[ -n "${WSREP_CLUSTER_ADDRESS}" ]]; then
    mkdir -p "${DATADIR}/mysql"
    echo "*** [Galera] Joining cluster: ${WSREP_CLUSTER_ADDRESS}"
else
    echo "*** [Galera] Starting new cluster!"
fi
