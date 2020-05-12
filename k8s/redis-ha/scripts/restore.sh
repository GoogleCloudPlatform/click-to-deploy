#!/bin/bash
#
# Copyright 2020 Google LLC
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

set -e

NAMESPACE="${NAMESPACE:-default}"

HELP_MESSAGE="# Set mandatory variables like below:
export APP_INSTANCE_NAME=redis-ha-1

To run backup restore:
# $0 redis-backup.rdb
"

# Ensure all required variables are provided.
if [[ -z "${APP_INSTANCE_NAME}" ]] || [[ ! -f "${1}" ]] || [[ "${1}" == "help" ]]; then
  echo "${HELP_MESSAGE}"
else
  LABEL_SELECTOR="app.kubernetes.io/name="${APP_INSTANCE_NAME}",app=redis-ha"

  # Simple validation of redis backup file
  head -c 9 "${1}" | grep -q -E '^REDIS[0-9]{4}$' \
    || (echo "Redis magic header doesn't exists in ${1}"; false)

  REPLICAS="$(kubectl -n "${NAMESPACE}" get statefulset \
    -l "${LABEL_SELECTOR}" \
    -o jsonpath='{range .items[*]}{.spec.replicas}{"\n"}{end}')"

  FIRST_POD="$(kubectl -n "${NAMESPACE}" \
    get pod -l "${LABEL_SELECTOR}" \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | head -n 1)"

  echo "Copy $1 to Pod: ${NAMESPACE}/${FIRST_POD}:/data/restore-dump.rdb"
  kubectl cp --container=redis \
    "${1}" "${NAMESPACE}"/"${FIRST_POD}":/data/restore-dump.rdb

  echo "Scale down redis stetefulset to 1 replica:"
  kubectl -n "${NAMESPACE}" scale statefulset \
    -l "${LABEL_SELECTOR}" \
    --replicas=1 --timeout=10m

  echo "Restarting ${FIRST_POD}:"
  kubectl -n "${NAMESPACE}" delete pod "${FIRST_POD}"

  echo "Waiting for Pod restart:"
  kubectl -n "${NAMESPACE}" wait --for=condition=ready pod "${FIRST_POD}"

  echo "Scale up statefulset to original replicas number: ${REPLICAS}"
  kubectl -n "${NAMESPACE}" scale statefulset \
      -l "${LABEL_SELECTOR}" \
      --replicas="${REPLICAS}"
  echo "Backup restored"
fi
