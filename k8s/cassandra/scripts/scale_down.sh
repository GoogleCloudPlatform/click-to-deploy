#!/bin/bash

function info {
  >&2 echo "${@}"
}

DESIRED_NUMBER=${1:-1}

NAMESPACE=${NAMESPACE:-default}
APP_INSTANCE_NAME=${APP_INSTANCE_NAME:-cassandra-1}
STS_NAME=${APP_INSTANCE_NAME}-cassandra

function get_desired_number_of_replicas_in_sts {
  kubectl get sts "${STS_NAME}" \
    --namespace "${NAMESPACE}" \
    --output jsonpath='{.spec.replicas}'
}

function get_current_number_of_replicas_in_sts {
  kubectl get sts "${STS_NAME}" \
    --namespace "${NAMESPACE}" \
    --output jsonpath='{.status.readyReplicas}'
}

function wait_for_healthy_sts {
  info "Waiting for equal desired and current number of replicas"
  while [[ $(get_current_number_of_replicas_in_sts) -ne $(get_desired_number_of_replicas_in_sts) ]]; do
    info "Sleeping 10 seconds before recheking..."
    sleep 10
  done
  info "Statefulset has equal current and desired number of replicas"
}

if [[ $DESIRED_NUMBER -gt $(get_desired_number_of_replicas_in_sts) ]]; then
  info "Desired number exceedes current number of desired replicas"
  exit 1
fi

if [[ $DESIRED_NUMBER -lt 1 ]]; then
  info "Cannot scale below 1"
  exit 1
fi

info "Current expected number of replicas is $(get_desired_number_of_replicas_in_sts)"
info "Scalling down to ${DESIRED_NUMBER} of replicas"
info "Parameter:"
info "Desired number of instance: ${DESIRED_NUMBER}"
info "K8s namespace: ${NAMESPACE}"
info "Application name: ${APP_INSTANCE_NAME}"
info "Statefulset name: ${STS_NAME}"
info ""

for i in $(seq $(( $(get_desired_number_of_replicas_in_sts) - 1 )) -1 $DESIRED_NUMBER); do
  $(wait_for_healthy_sts)
  info "Removing Cassandra node ${i} from Cassandra cluster"
  kubectl exec "${APP_INSTANCE_NAME}-cassandra-${i}" --namespace $NAMESPACE -c cassandra -- nodetool decommission
  info "Removing pod ${APP_INSTANCE_NAME}-cassandra-${i} from stateful set"
  kubectl scale statefulsets cassandra-1-cassandra -n $NAMESPACE "--replicas=${i}"
  $(wait_for_healthy_sts)
  PV_NAME=$(kubectl get pvc -n $NAMESPACE "${APP_INSTANCE_NAME}-cassandra-pvc-${APP_INSTANCE_NAME}-cassandra-${i}" --output jsonpath='{.spec.volumeName}')
  info "Removing persitent volumes and persitent volume claims for pod ${APP_INSTANCE_NAME}-cassandra-${i}"
  kubectl delete pvc/"${APP_INSTANCE_NAME}-cassandra-pvc-${APP_INSTANCE_NAME}-cassandra-${i}" -n "$NAMESPACE"
  kubectl delete pv/"${PV_NAME}" -n "$NAMESPACE"
  info ""
done

$(wait_for_healthy_sts)

info ""
info "Done"
