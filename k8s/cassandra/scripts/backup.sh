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
This script creates a backup files from Cassandra cluster. Following files
are generated:
- multiple backup .tar.gz archives, containing raw data from Cassandra. For each
  Cassandra node one archive is generated
- backup-schema.cql schema file
- backup-ring.info file, with ring information, useful for manual restore

Parameters:
--keyspace             (Required) Name of Cassandra keyspace to backup
--namespace            (Required) Name of K8s namespace, where Cassandra
                       cluster exists
--app_instance_name    (Required) Name of application in K8s cluster

Example:
<SCRIPT DIR>/backup.sh --keyspace demo \
                       --namespace custom-namespace \
                       --app_instance_name cassandra-1
'

. "${SCRIPT_DIR}/util.sh"

add_flag_with_argument KEYSPACE keyspace

init_util $@

required_variables KEYSPACE

function upload_backup_script_cmd {
  for index in $(seq 0 $(( "${REPLICAS}" - 1 )) ); do
    echo "kubectl cp ${SCRIPT_DIR}/make_backup.sh ${APP_INSTANCE_NAME}-cassandra-${index}:/make_backup.sh -n $NAMESPACE"
  done
}

function backup_containers_cmd {
  for index in $(seq 0 $(( "${REPLICAS}" - 1 )) ); do
    echo "kubectl exec ${APP_INSTANCE_NAME}-cassandra-${index} -n $NAMESPACE -- /make_backup.sh ${KEYSPACE}"
  done
}

function get_backups_containers_cmd {
  for index in $(seq 0 $(( "${REPLICAS}" - 1 )) ); do
    echo "kubectl cp ${APP_INSTANCE_NAME}-cassandra-${index}:/tmp/backup.tar.gz backup-${index}.tar.gz -n $NAMESPACE"
  done
}

function delete_files_from_containers_cmd {
  for index in $(seq 0 $(( "${REPLICAS}" - 1 )) ); do
    for path in "/make_backup.sh" "/tmp/backup.tar.gz" "/tmp/backup"; do
      echo "kubectl exec ${APP_INSTANCE_NAME}-cassandra-${index} -n $NAMESPACE -- rm -rf ${path}"
    done
  done
}

current_status
info "Preparing to make a backup of keyspace '$KEYSPACE'"

wait_for_healthy_sts

REPLICAS=$(get_desired_number_of_replicas_in_sts)

info "Performing backup of ${REPLICAS} containers"

info "Uploading backup script"
upload_backup_script_cmd "${REPLICAS}" | parallel
if [[ $? -ne 0 ]]; then
  info "Cannot upload backup script"
  exit 1
fi

info "Running backup script"
backup_containers_cmd "${REPLICAS}" | parallel
STATUS=$?
if [[ $STATUS -ne 0 ]]; then
  info "Backup failed, $STATUS failed of ${REPLICAS} backub jobs"
# Check for one of possible reasons for error, Cassandra cluster was scaled during
# backup procedure
  NEW_REPLICAS=$(get_desired_number_of_replicas_in_sts)
  if [[ "${REPLICAS}" -ne "${NEW_REPLICAS}" ]]; then
    info "Number of containers has changed from ${REPLICAS} to ${NEW_REPLICAS}"
  fi
  exit 1
fi

info ""
info "Downloading backups"
info ""
get_backups_containers_cmd "${REPLICAS}" | parallel
if [[ $? -ne 0 ]]; then
  info "Downloading backups failed"
  exit 1
fi
info "Backup is successful"
info ""
info "Removing files from pods"
info ""
delete_files_from_containers_cmd "${REPLICAS}" | parallel
if [[ $? -ne 0 ]]; then
  info "Removing failed"
  exit 1
fi


info "Getting schema..."
info ""
kubectl exec ${APP_INSTANCE_NAME}-cassandra-0 -n $NAMESPACE -c cassandra -- cqlsh -e "DESC KEYSPACE ${KEYSPACE}" > backup-schema.cql

info "Getting ring info..."
info ""
kubectl exec ${APP_INSTANCE_NAME}-cassandra-0 -n $NAMESPACE -c cassandra -- nodetool ring > backup-ring.info

info ""
info "Backups..."
ls -al backup-*.tar.gz
info ""
info "Schema file..."
ls -al backup-schema.cql
info ""
info "Ring information..."
ls -al backup-ring.info
info ""

info "Done"
