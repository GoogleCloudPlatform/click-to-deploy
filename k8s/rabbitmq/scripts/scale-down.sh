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

# While scaling down we want to gracefully remove a RabbitMQ node from the cluster.
#
# RabbitMQ CLI is used to detach nodes from the cluster.
# Then kubectl command removes the Pod, persistent volumes and persistent volume claims.

set -euo pipefail

function get_desired_number_of_replicas_in_sts() {
  # Return the desired number of replicas of the given Template.
  local -r namespace="$1"
  local -r sts_name="$2"
  kubectl get sts "${sts_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.spec.replicas}'
}

function get_current_number_of_replicas_in_sts() {
  # Return the number of Pods created by the StatefulSet controller.
  local -r namespace="$1"
  local -r sts_name="$2"
  kubectl get sts "${sts_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.status.replicas}'
}

function get_pv_name() {
  local -r namespace="$1"
  local -r pvc_name="$2"
  kubectl get pvc "${pvc_name}" \
    --namespace "${namespace}" \
    --output jsonpath='{.spec.volumeName}'
}

function wait_for_healthy_sts() {
  local -r namespace="$1"
  local -r pvc_name="$2"

  local -i current_desired_replicas="$(get_desired_number_of_replicas_in_sts "${namespace}" "${sts_name}")"
  local -i current_replicas="$(get_current_number_of_replicas_in_sts "${namespace}" "${sts_name}")"
  while [[ "${current_desired_replicas}" != "${current_replicas}" ]]; do
    echo "Waiting for stable Pods status... It can take a moment"
    sleep 15
    current_desired_replicas="$(get_desired_number_of_replicas_in_sts "${namespace}" "${sts_name}")"
    current_replicas="$(get_current_number_of_replicas_in_sts "${namespace}" "${sts_name}")"
  done
}

function print_usage() {
  echo "Usage:"
  echo "$0 --app [APP_INSTANCE_NAME] --namespace [NAMESPACE] --replicas [COUNT]"
}

function main() {
  while [[ $# -gt 0 ]]; do
    # TODO(wgrzelak): Fix '$2: unbound variable', when a parameter value is empty.
    case "$1" in
      --app)
        local -r app="$2"
        shift 2
        ;;
      --namespace)
        local -r namespace="$2"
        shift 2
        ;;
      --replicas)
        # The new desired number of replicas.
        local -ri replicas="$2"
        shift 2
        ;;
      --help)
        print_usage
        exit 0
        ;;
      *)
        echo "Unrecognized flag: $1"
        print_usage
        exit 1
        ;;
    esac
  done;

  # Check if all flags were provided.
  for var in app namespace replicas; do
    if ! [[ -v "${var}" ]]; then
      echo "Parameter '--${var}' is required"
      print_usage
      exit 1
    fi
  done

  if (( "${replicas}" < 1 )); then
    echo "Sorry, cannot scale below 1"
    exit 1
  fi

  local -r sts_name="${app}-rabbitmq"
  local -i current_desired_replicas="$(get_desired_number_of_replicas_in_sts "${namespace}" "${sts_name}")"

  echo "============================================="
  echo "| Application:      ${app}"
  echo "| K8s namespace:    ${namespace}"
  echo "| StatefulSets:     ${sts_name}"
  echo "| Current replicas: ${current_desired_replicas}"
  echo "| New replicas:     ${replicas}"
  echo "============================================="

  wait_for_healthy_sts "${namespace}" "${sts_name}"

  echo "Starting scaling down..."
  while (( "${current_desired_replicas}" > "${replicas}" )); do
    local -i pod_index="$(( current_desired_replicas - 1 ))"
    local pod_name="${sts_name}-${pod_index}"
    local pvc_name="${sts_name}-pvc-${pod_name}"
    local pv_name="$(get_pv_name "${namespace}" "${pvc_name}")"

    # remove a node from cluster
    kubectl exec -it "${pod_name}" --namespace "${namespace}" -- rabbitmqctl stop_app
    kubectl exec -it "${pod_name}" --namespace "${namespace}" -- rabbitmqctl reset
    # scale down by one Pod
    kubectl scale statefulsets "${sts_name}" --namespace "${namespace}" --replicas="${pod_index}"
    # wait until StatefulSet is healthy
    wait_for_healthy_sts "${namespace}" "${sts_name}"
    # delete persistentvolumes and persistentvolumeclaims
    kubectl delete "pvc/${pvc_name}" --namespace "${namespace}"
    kubectl delete "pv/${pv_name}" --namespace "${namespace}"

    current_desired_replicas="$(get_desired_number_of_replicas_in_sts "${namespace}" "${sts_name}")"

    # This check is to stop the script in case another process is scaling the cluster
    # or someone does it manually.
    if [[ "${current_desired_replicas}" != "${pod_index}" ]]; then
      echo "Something went wrong, it looks like another process also wants to scale the cluster"
      exit 2
    fi
  done
  echo "DONE :)"
}

main "$@"
