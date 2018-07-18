#!/bin/bash
#
# Copyright 2018 Google LLC
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

export SCRIPT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

if [[ ! -f "${SCRIPT_DIR}/util.sh" ]]; then
  >&2 echo "Missing util.sh file, exiting"
  exit 1
fi

USAGE='
Upgrade script to Cassandra cluster running on K8s. Gracefully shuting down,
recreating new pod and waiting for healthy status of the cluster.

Parameters:
--namespace            (Required) Name of K8s namespace, where Cassandra
                       cluster exists
--app_instance_name    (Required) Name of application in K8s cluster

Example:
<SCRIPT DIR>/upgrade.sh    --namespace custom-namespace \
                           --app_instance_name cassandra-1
'

. "${SCRIPT_DIR}/util.sh"

init_util $@

function delete_pod() {
  local -r pod_name="$1"
  kubectl delete pod "${pod_name}" --namespace "${NAMESPACE}"
}


function get_pod_uid() {
  local -r pod_name="$1"
  kubectl get pod "${pod_name}" \
    --namespace "${NAMESPACE}" \
    --output jsonpath='{.metadata.uid}'
}


function get_pod_status() {
  local -r pod_name="$1"
  kubectl get pod "${pod_name}" \
    --namespace "${NAMESPACE}" \
    --output jsonpath='{.status.phase}'
}


function recreate_pod() {
  local -r pod_name="$1"

  local -r old_uid="$(get_pod_uid "${pod_name}")"
  info "Old pod UID: ${old_uid} - deleting..."
  delete_pod "${pod_name}"

  local new_uid="$(get_pod_uid "${pod_name}")"
  local status="$(get_pod_status "${pod_name}")"

  while [[ "${new_uid}" == "${old_uid}" ]] || [[ "${status}" != "Running" ]]; do
    info "Waiting for new pod status: Running..."
    sleep 5
    new_uid="$(get_pod_uid "${pod_name}")"
    status="$(get_pod_status "${pod_name}")"
  done
  info "Pod is running (UID: ${new_uid})."
}

function exec_nodetool() {
  local -r pod_name="$1"
  shift

  kubectl exec "${pod_name}" -c cassandra -n "${NAMESPACE}" -- nodetool $@
}

current_status

wait_for_healthy_sts

# Rolling update procedure:
info "Starting the rolling update procedure on the cluster..."

for node_number in $(seq $(( $(get_desired_number_of_replicas_in_sts) - 1 )) -1 0); do
  POD_NAME="${STS_NAME}-${node_number}"

  info "Performing update on pod: ${POD_NAME}..."
  exec_nodetool "${POD_NAME}" drain
  recreate_pod "${POD_NAME}"

  wait_for_healthy_sts
  exec_nodetool "${POD_NAME}" upgradesstables
  wait_for_healthy_sts
done

info "Update procedure of your Cassandra StatefulSet has been finished."
