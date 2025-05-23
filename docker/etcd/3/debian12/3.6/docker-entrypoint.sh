#!/bin/bash
#
# Copyright 2019 Google LLC.
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

# Check if Root password is provided
if [[ ! -z "${ETCD_ROOT_PASSWORD}" ]]; then
    echo "==> Enabling etcd authentication..."
    # Starting etcd daemon
    etcd > /dev/null 2>&1 &
    ETCD_PID=$!
    while ! etcdctl member list &>/dev/null; do sleep 1; done
    # Creating root user and setting password
    etcdctl user add root:"${ETCD_ROOT_PASSWORD}"
    # Grant root role to root user if it doesn't exist
    etcdctl user get root | grep Roles | grep --silent root
    if [ $? != 0 ]; then
        etcdctl user grant-role root root
    fi
    # Enabling Authentication
    etcdctl auth enable
    # Killing etcd daemon
    kill "${ETCD_PID}"
else
    echo "ETCD_ROOT_PASSWORD is required"
    exit 1
fi

exec "$@"
