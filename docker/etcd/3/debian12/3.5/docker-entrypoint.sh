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

set -euo pipefail

# Check if Root password is provided
if [[ -z "${ETCD_ROOT_PASSWORD:-}" ]]; then
    echo "ETCD_ROOT_PASSWORD is required"
    exit 1
fi

echo "==> Enabling etcd authentication..."

BOOTSTRAP_CLIENT_URL="http://127.0.0.1:2379"
BOOTSTRAP_PEER_URL="http://127.0.0.1:2380"
BOOTSTRAP_NAME="${ETCD_NAME:-default}"

bootstrap_etcd_env=(
    "PATH=${PATH}"
    "HOME=${HOME:-/root}"
    "ETCD_NAME=${BOOTSTRAP_NAME}"
    "ETCD_LISTEN_CLIENT_URLS=${BOOTSTRAP_CLIENT_URL}"
    "ETCD_ADVERTISE_CLIENT_URLS=${BOOTSTRAP_CLIENT_URL}"
    "ETCD_LISTEN_PEER_URLS=${BOOTSTRAP_PEER_URL}"
    "ETCD_INITIAL_ADVERTISE_PEER_URLS=${BOOTSTRAP_PEER_URL}"
    "ETCD_INITIAL_CLUSTER=${BOOTSTRAP_NAME}=${BOOTSTRAP_PEER_URL}"
    "ETCD_INITIAL_CLUSTER_STATE=new"
)
if [[ -n "${ETCD_DATA_DIR:-}" ]]; then
    bootstrap_etcd_env+=("ETCD_DATA_DIR=${ETCD_DATA_DIR}")
fi
if [[ -n "${ETCD_BCRYPT_COST:-}" ]]; then
    bootstrap_etcd_env+=("ETCD_BCRYPT_COST=${ETCD_BCRYPT_COST}")
fi

bootstrap_etcdctl() {
    env -i \
        "PATH=${PATH}" \
        "ETCDCTL_ENDPOINTS=${BOOTSTRAP_CLIENT_URL}" \
        etcdctl "$@"
}

ETCD_PID=""
cleanup_bootstrap() {
    if [[ -n "${ETCD_PID}" ]] && kill -0 "${ETCD_PID}" 2>/dev/null; then
        kill "${ETCD_PID}" 2>/dev/null || true
        wait "${ETCD_PID}" 2>/dev/null || true
    fi
}
trap cleanup_bootstrap EXIT

# Start a temporary etcd instance bound strictly to loopback with a clean
# environment so the unauthenticated bootstrap window is never reachable over
# the network and is unaffected by operator TLS/URL/config env vars.
env -i "${bootstrap_etcd_env[@]}" etcd > /dev/null 2>&1 &
ETCD_PID=$!

# Wait until bootstrap etcd is ready to serve AuthStatus RPCs.
auth_enabled=false
while true; do
    if ! kill -0 "${ETCD_PID}" 2>/dev/null; then
        echo "ERROR: bootstrap etcd exited unexpectedly" >&2
        exit 1
    fi
    auth_status_out=$(bootstrap_etcdctl auth status 2>&1 || true)
    if [[ "${auth_status_out}" == *"Authentication Status: false"* ]]; then
        break
    elif [[ "${auth_status_out}" == *"Authentication Status: true"* ]] \
        || [[ "${auth_status_out}" == *"etcdserver: user name is empty"* ]]; then
        auth_enabled=true
        break
    fi
    sleep 0.2
done

if [[ "${auth_enabled}" == "false" ]]; then
    # Creating root user and setting password via stdin to avoid exposing it in argv
    if ! root_info=$(bootstrap_etcdctl user get root 2>/dev/null); then
        printf '%s\n' "${ETCD_ROOT_PASSWORD}" | bootstrap_etcdctl user add root --interactive=false
        root_info=$(bootstrap_etcdctl user get root)
    fi
    # Grant root role to root user if it doesn't exist
    if ! printf '%s\n' "${root_info}" | grep -E '^Roles:.*\broot\b' >/dev/null; then
        bootstrap_etcdctl user grant-role root root
    fi
    # Enabling Authentication
    bootstrap_etcdctl auth enable
else
    echo "==> etcd authentication is already enabled."
fi

# Stop bootstrap etcd and wait for it to release the data dir lock.
cleanup_bootstrap
ETCD_PID=""
trap - EXIT

# Clear ETCD_ROOT_PASSWORD before exec so etcd does not log it as an
# unrecognized ETCD_* environment variable.
unset ETCD_ROOT_PASSWORD

exec "$@"
