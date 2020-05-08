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

HELP_MESSAGE="# Set mandatory variables as below:
export APP_INSTANCE_NAME=redis-ha-1"

# Ensure all required variables are provided.
if [[ -z "${APP_INSTANCE_NAME}" ]] || [[ "${1}" == "help" ]]; then
  echo "${HELP_MESSAGE}"
else
  REDIS_MASTER=$(kubectl -n "${NAMESPACE}" get pod \
    -l app.kubernetes.io/name="${APP_INSTANCE_NAME}",app=redis-ha \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
    | xargs -I {} kubectl exec {} --container=redis -- sh -c \
    "redis-cli -a \"\${AUTH}\" info | grep -q ^role:master && echo {} || true" 2>/dev/null)
  echo "Redis master Pod: ${REDIS_MASTER}"

  echo "Trigger redis to save backup and make copy for prevent overriding while it coping:"
  BACKUP_FILE=redis-backup-"$(date +%Y%m%d_%H%M%S%z)".rdb
  kubectl exec -n "${NAMESPACE}" "${REDIS_MASTER}" --container=redis -- \
    sh -c "redis-cli -a \"\${AUTH}\" SAVE 2>/dev/null; \
    cp /data/dump.rdb /data/\"${BACKUP_FILE}\""

  echo "Copying file to local environment:"
  kubectl cp --container=redis \
    "${NAMESPACE}"/"${REDIS_MASTER}":/data/"${BACKUP_FILE}" "${BACKUP_FILE}"
  echo "Backup saved as ${BACKUP_FILE}"
fi
