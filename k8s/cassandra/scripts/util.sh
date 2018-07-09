#!/bin/bash

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

function parse_argument {
  local exported_variable=$1
  local name_of_variable=$2

  shift 2
  while [[ "$#" != 0 ]]; do
    case "$1" in
      --$name_of_variable)
        export "${exported_variable}"="$2"
        info "- ${name_of_variable}: ${!exported_variable}"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done;
}

function parse_argument_with_default {
  local exported_variable=$1
  local name_of_variable=$2
  local default_vaule=$3

  shift 3
  export "${exported_variable}=${default_vaule}"
  parse_argument "${exported_variable}" "${name_of_variable}" $@
}

function parse_required_argument {
  local exported_variable=$1
  local name_of_variable=$2

  shift 2
  parse_argument "${exported_variable}" "${name_of_variable}" $@
  if [[ ! -v "${exported_variable}" ]]; then
    info "${USAGE}"
    info ""
    info "Missing parameter --${name_of_variable}"
    exit 1
  fi
}

function show_help {
  while [[ "$#" != 0 ]]; do
    case "$1" in
      --help)
        info "${USAGE}"
        exit 0
        ;;
      *)
        shift
        ;;
    esac
  done;
}

show_help $@

parse_argument_with_default NAMESPACE namespace default $@
parse_argument_with_default APP_INSTANCE_NAME app_instance_name cassandra-1 $@
STS_NAME=${APP_INSTANCE_NAME}-cassandra
