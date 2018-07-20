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

function show_help {
  if [[ "${SHOW_HELP}" == true ]]; then
    info "${USAGE}"
    exit 0
  fi
}

declare -a flags_variables_with_argument=()
declare -a flags_parameters_with_argument=()
declare -a flags_variables_boolean=()
declare -a flags_parameters_boolean=()

function add_flag_with_argument {
  flags_variables_with_argument+=($1)
  flags_parameters_with_argument+=($2)
}

function add_flag_boolean {
  flags_variables_boolean+=($1)
  flags_parameters_boolean+=($2)
}

function parse_flags {
  for i in $( seq 0 $(( ${#flags_parameters_boolean[@]} - 1 )) ); do
    export ${flags_variables_boolean[${i}]}=false
  done
  while [[ $# -gt 0 ]]; do
    found=false
    if [[ $# -gt 1 ]]; then
      for i in $( seq 0 $(( ${#flags_parameters_with_argument[@]} - 1 )) ); do
        if [[ "--${flags_parameters_with_argument[${i}]}" == "$1" ]]; then
          export ${flags_variables_with_argument[${i}]}=$2
          shift 2
          found=true
          break
        fi
      done
    fi
    if [[ $# -gt 0 ]]; then
      for i in $( seq 0 $(( ${#flags_parameters_boolean[@]} - 1 )) ); do
        if [[ "--${flags_parameters_boolean[${i}]}" == "$1" ]]; then
          export ${flags_variables_boolean[${i}]}=true
          shift
          found=true
          break
        fi
      done
    fi
    if [[ $found == false ]]; then
      echo "Cannot parse parameter $1"
      info "${USAGE}"
      exit 1
    fi
  done
}

function required_variables {
  for i in $@; do
    if [[ ! -v $i ]]; then
      info "${USAGE}"
      exit 1
    fi
  done
}

function init_util {
  parse_flags $@
  show_help
  required_variables APP_INSTANCE_NAME NAMESPACE
  STS_NAME=${APP_INSTANCE_NAME}-cassandra
}

add_flag_boolean SHOW_HELP help
add_flag_with_argument NAMESPACE namespace
add_flag_with_argument APP_INSTANCE_NAME app_instance_name
