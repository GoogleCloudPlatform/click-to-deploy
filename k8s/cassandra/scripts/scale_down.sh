#!/bin/bash

# While scaling down we want to gracefully remove Cassandra node from cluster,
# moving all data that belong to that node to other nodes and stop all writes
# to this node.
#
# To do this, we use `nodetool decommission` command, that marks node as 'to be
# removed', also on disk. This disk cannot be used again to connect to this
# cluster, as Cassandra has marked that this disk belongs to decommissioned
# node. Thus, we need to delete this disk, removing PV and PVC.

set -euo pipefail

export SCRIPT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

if [[ ! -f "${SCRIPT_DIR}/util.sh" ]]; then
  >&2 echo "Missing util.sh file, exiting"
  exit 1
fi

. "${SCRIPT_DIR}/util.sh"

DESIRED_NUMBER=${1:-1}

if [[ $DESIRED_NUMBER -gt $(get_desired_number_of_replicas_in_sts) ]]; then
  info "Desired number exceedes current number of desired replicas"
  exit 1
fi

if [[ $DESIRED_NUMBER -lt 1 ]]; then
  info "Cannot scale below 1"
  exit 1
fi

current_status

info "Scalling down to ${DESIRED_NUMBER} of replicas"

for node_number in $(seq $(( $(get_desired_number_of_replicas_in_sts) - 1 )) -1 $DESIRED_NUMBER); do
  POD_NAME="${STS_NAME}-${node_number}"
  PVC_NAME="${STS_NAME}-pvc-${POD_NAME}"
  PV_NAME=$(kubectl get pvc -n "${NAMESPACE}" "${PVC_NAME}" --output jsonpath='{.spec.volumeName}')

  wait_for_healthy_sts
  info "Removing Cassandra node ${node_number} from Cassandra cluster"
  kubectl exec "${POD_NAME}" --namespace "${NAMESPACE}" -c cassandra -- nodetool decommission
  info "Removing pod ${POD_NAME} from stateful set ${STS_NAME}"
  kubectl scale statefulsets "${STS_NAME}" -n "${NAMESPACE}" "--replicas=${node_number}"
  wait_for_healthy_sts
  info "Removing persitent volumes and persitent volume claims for pod ${POD_NAME}"
  kubectl delete "pvc/${PVC_NAME}" -n "${NAMESPACE}"
  kubectl delete "pv/${PV_NAME}" -n "${NAMESPACE}"
  info ""
done

wait_for_healthy_sts

info ""
info "Done"
