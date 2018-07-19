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

readonly ES_SHARD_ENABLED_VALUE=null
readonly ES_SHARD_DISABLED_VALUE=\"none\"

function wait_for_green_elastic_cluster() {
  local -r elastic_url="$1"
  local -r health_url="${elastic_url}/_cluster/health"
  local -r status_health_url="${health_url}?filter_path=status"
  local status="$(curl -s -m 2 -X GET "${status_health_url}" \
    | sed -nr 's/\{"status":"(.*)"\}/\1/p')"
  until [[ "${status}" == "green" ]]; do
    echo "Current status: ${status}. Waiting for status green..."
    sleep 5
    local status="$(curl -s -m 2 -X GET "${status_health_url}" \
      | sed -nr 's/\{"status":"(.*)"\}/\1/p')"
  done
  echo "Cluster status: green"
}


function wait_for_nodes_in_cluster() {
  local -r elastic_url="$1"
  local -r expected_nodes="$2"
  local nodes_in_cluster="$(curl -s -m 2 -X GET "${elastic_url}/_cat/nodes" | wc -l)"
  until [[ "${nodes_in_cluster}" = "${expected_nodes}" ]]; do
    echo "Nodes in the cluster: $nodes_in_cluster. Waiting for ${expected_nodes}..."
    sleep 5
    nodes_in_cluster=$(curl -s -m 5 -X GET "${elastic_url}/_cat/nodes" | wc -l)
  done
  echo "The cluster has the expected number of nodes: $expected_nodes."
}


function set_shard_allocation() {
  local -r elastic_url="$1"
  local -r value="$2"
  curl -s -X PUT "${elastic_url}/_cluster/settings" \
    -H 'Content-Type: application/json' \
    -d "{ \
         \"persistent\": { \
           \"cluster.routing.allocation.enable\": ${value} \
         } \
       }" > /dev/null
  echo "Shard allocation in cluster set to ${value}."
}


function perform_synced_flush() {
  local -r elastic_url="$1"
  curl -s -X POST "${elastic_url}/_flush/synced" > /dev/null
  echo "Synced flush operation done."
}


function get_number_of_replicas_in_sts() {
  local -r namespace="$1"
  local -r sts_name="$2"
  kubectl get sts "${sts_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.spec.replicas}'
}


function delete_pod() {
  local -r namespace="$1"
  local -r pod_name="$2"
  kubectl delete pod "${pod_name}" --namespace "${namespace}"
}


function get_pod_uid() {
  local -r namespace="$1"
  local -r pod_name="$2"
  kubectl get pod "${pod_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.metadata.uid}'
}


function get_pod_status() {
  local -r namespace="$1"
  local -r pod_name="$2"
  kubectl get pod "${pod_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.status.phase}'
}


function recreate_pod() {
  local -r namespace="$1"
  local -r pod_name="$2"

  local -r old_uid="$(get_pod_uid "${namespace}" "${pod_name}")"
  echo "Old pod UID: ${old_uid} - deleting..."
  delete_pod "${namespace}" "${pod_name}"

  local new_uid="$(get_pod_uid "${namespace}" "${pod_name}")"
  local status="$(get_pod_status "${namespace}" "${pod_name}")"
  while [[ "${new_uid}" == "${old_uid}" ]] || [[ "${status}" != "Running" ]]; do
    echo "Waiting for new pod status: Running..."
    sleep 5
    new_uid="$(get_pod_uid "${namespace}" "${pod_name}")"
    status="$(get_pod_status "${namespace}" "${pod_name}")"
  done
  echo "Pod is running (UID: ${new_uid})."
}


function main() {
  while [[ "$#" != 0 ]]; do
    case "$1" in
      --app)
        local -r app="$2"
        echo "- app: $app"
        shift 2
        ;;
      --namespace)
        local -r namespace="$2"
        echo "- namespace: $namespace"
        shift 2
        ;;
      --elastic_url)
        local -r elastic_url="$2"
        echo "- elastic_url: $elastic_url"
        shift 2
        ;;
      *)
        echo "Unsupported flag: $1 - EXIT"
        exit 1
    esac
  done;

  # Check if all flags were provided:
  for var in app namespace elastic_url; do
    if ! [[ -v "${var}" ]]; then
      echo "Missing flag --${var} - EXIT"
      exit 1
    fi
  done

  local -r sts_name="${app}-elasticsearch"
  local -r replicas="$(get_number_of_replicas_in_sts "${namespace}" "${sts_name}")"

  # Perform the initial validation of Elasticsearch cluster:
  echo "Checking if the cluster is healthy and all pods joined the cluster..."
  wait_for_green_elastic_cluster "${elastic_url}"
  wait_for_nodes_in_cluster "${elastic_url}" "${replicas}"

  # Rolling update procedure:
  echo "Starting the rolling update procedure on the cluster..."
  local pod_no="$(( replicas - 1 ))"
  while (( pod_no  >= 0 )); do
    local pod_name="${sts_name}-${pod_no}"
    echo "Performing update on pod: ${pod_name}..."
    set_shard_allocation "${elastic_url}" "${ES_SHARD_DISABLED_VALUE}"
    perform_synced_flush "${elastic_url}"
    recreate_pod "${namespace}" "${pod_name}"
    wait_for_nodes_in_cluster "${elastic_url}" "${replicas}"
    set_shard_allocation "${elastic_url}" "${ES_SHARD_ENABLED_VALUE}"
    wait_for_green_elastic_cluster "${elastic_url}"
    (( pod_no-- ))
  done

  echo "Update procedure of your Elasticseach StatefulSet has been finished."
}

main "$@"
