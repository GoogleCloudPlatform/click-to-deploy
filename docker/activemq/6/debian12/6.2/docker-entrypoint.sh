#!/bin/bash
#
# Copyright 2024 Google LLC
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

# Defines if admin panel website will be bind all hosts or only localhost
: ${ACTIVEMQ_ADMIN_BIND_ALL:=false}

if [[ "${ACTIVEMQ_ADMIN_BIND_ALL}" == "true" ]]; then
    sed -i 's|<property name="host" value="127.0.0.1"/>|<property name="host" value="0.0.0.0"/>|g' \
        "${ACTIVEMQ_HOME}/conf/jetty.xml"
fi

# Set admin password if defined.
if [[ ! -z "${ACTIVEMQ_ADMIN_PASSWORD}" ]]; then
    activemq_major="$(echo "${ACTIVEMQ_VERSION}" | cut -d '.' -f 1)"

    # ActiveMQ 5
    if [[ "${activemq_major}" -eq 5 ]]; then
        sed -i "/admin/ c admin: "${ACTIVEMQ_ADMIN_PASSWORD}", admin" "${ACTIVEMQ_HOME}/conf/jetty-realm.properties"
    fi

    # ActiveMQ 6
    if [[ "${activemq_major}" -eq 6 ]]; then
        sed -i "s/admin=admin/admin=$ACTIVEMQ_ADMIN_PASSWORD/g" "${ACTIVEMQ_HOME}/conf/users.properties"
    fi
else
    echo "ACTIVEMQ_ADMIN_PASSWORD is required"
    exit 1
fi

exec "$@"
