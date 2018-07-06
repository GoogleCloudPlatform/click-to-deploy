#!/bin/bash

NAMESPACE=${NAMESPACE:-default}
APP_INSTANCE_NAME=${APP_INSTANCE_NAME:-cassandra-1}
STS_NAME=${APP_INSTANCE_NAME}-cassandra

function info {
  >&2 echo "${@}"
}

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
    info "Sleeping 10 seconds before rechecking..."
    sleep 10
  done
  info "Statefulset has equal current and desired number of replicas"
}

function current_status {
  info "Parameters:"
  info "K8s namespace: ${NAMESPACE}"
  info "Application name: ${APP_INSTANCE_NAME}"
  info "Statefulset name: ${STS_NAME}"
  info ""
  info "Current expected number of replicas is $(get_desired_number_of_replicas_in_sts)"
  info ""
}
