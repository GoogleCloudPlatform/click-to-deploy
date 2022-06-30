#!/bin/bash
#
# Copyright 2020 Google LLC
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

# Enable bash debug if DEBUG_DOCKER_ENTRYPOINT exists.
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi

set -e

# Allow the container to be started with `--user`
if [[ "$1" = 'zkServer.sh' && "$(id -u)" = '0' ]]; then
    chown -R zookeeper "${ZOO_DATA_DIR}" "${ZOO_DATA_LOG_DIR}" "${ZOO_LOG_DIR}" "${ZOO_CONF_DIR}"
    exec gosu zookeeper "$0" "$@"
fi

# Generate the config only if it doesn't exist
if [[ ! -f "${ZOO_CONF_DIR}/zoo.cfg" ]]; then
    CONFIG="${ZOO_CONF_DIR}/zoo.cfg"
    {
        echo "dataDir=${ZOO_DATA_DIR}"
        echo "dataLogDir=${ZOO_DATA_LOG_DIR}"

        echo "tickTime=${ZOO_TICK_TIME}"
        echo "initLimit=${ZOO_INIT_LIMIT}"
        echo "syncLimit=${ZOO_SYNC_LIMIT}"

        echo "autopurge.snapRetainCount=${ZOO_AUTOPURGE_SNAPRETAINCOUNT}"
        echo "autopurge.purgeInterval=${ZOO_AUTOPURGE_PURGEINTERVAL}"
        echo "maxClientCnxns=${ZOO_MAX_CLIENT_CNXNS}"
        echo "standaloneEnabled=${ZOO_STANDALONE_ENABLED}"
        echo "admin.enableServer=${ZOO_ADMINSERVER_ENABLED}"
    } >> "${CONFIG}"
    if [[ -z "${ZOO_SERVERS}" ]]; then
      ZOO_SERVERS="server.1=localhost:2888:3888;2181"
    fi

    for server in ${ZOO_SERVERS}; do
        echo "${server}" >> "${CONFIG}"
    done

    if [[ -n "${ZOO_4LW_COMMANDS_WHITELIST}" ]]; then
        echo "4lw.commands.whitelist=${ZOO_4LW_COMMANDS_WHITELIST}" >> "${CONFIG}"
    fi

    for cfg_extra_entry in "${ZOO_CFG_EXTRA}"; do
        echo "${cfg_extra_entry}" >> "${CONFIG}"
    done
fi

# Write myid only if it doesn't exist
if [[ ! -f "${ZOO_DATA_DIR}/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "${ZOO_DATA_DIR}/myid"
fi

exec "$@"
