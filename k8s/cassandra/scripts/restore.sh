#!/bin/bash

set -euo pipefail

export SCRIPT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

if [[ ! -f "${SCRIPT_DIR}/util.sh" ]]; then
  >&2 echo "Missing util.sh file, exiting"
  exit 1
fi

USAGE='
This script restores Cassandra cluster data from backup files. Following files
are required:
- multiple backup .tar.gz archives, containing raw data
- backup-schema.cql schema file

Parameters:
--keyspace             (Required) Name of Cassandra keyspace to backup
--backups              (Required) Number of backup .tar.gz archives
--namespace            (Required) Name of K8s namespace, where Cassandra
                       cluster exists
--app_instance_name    (Required) Name of application in K8s cluster

Example:
<SCRIPT DIR>/restores.sh   --keyspace demo \
                           --backups 3 \
                           --namespace custom-namespace
'

. "${SCRIPT_DIR}/util.sh"

add_flag_with_argument KEYSPACE keyspace
add_flag_with_argument BACKUPS backups

init_util $@

required_variables KEYSPACE BACKUPS

current_status
info "Preparing to restore a backup of keyspace '${KEYSPACE}' from ${BACKUPS} archieves"

wait_for_healthy_sts

info "Checking if required files exists"
for backup in $(seq 0 $(( "${BACKUPS}" - 1 )) ); do
  if [[ ! -f "backup-${backup}.tar.gz" ]]; then
    info "Missing backup-${backup}.tar.gz"
    exit 1
  fi
done
if [[ ! -f backup-schema.cql ]]; then
  info "Missing backup-schema.cql"
  exit 1
fi
info "All required files are available"

REPLICAS=$(get_desired_number_of_replicas_in_sts)
info "Performing restore of ${REPLICAS} sized cluster"

info "Restoring schema"
kubectl exec -i "${APP_INSTANCE_NAME}-cassandra-0" -n "${NAMESPACE}" -c cassandra -- \
  cqlsh < backup-schema.cql

info "Creating restore instance"
info ""
kubectl apply -f "${SCRIPT_DIR}/controller.yaml" -n "${NAMESPACE}"
info "Uploading restore script"
info ""
kubectl cp "${SCRIPT_DIR}/instance_restore.sh" cassandra-restore:/tmp/instance_restore.sh -n "${NAMESPACE}"
SEEDS=$(kubectl get sts -n "${NAMESPACE}" "${STS_NAME}" \
          -ojsonpath='{.spec.template.spec..containers[0].env[?(@.name=="CASSANDRA_SEEDS")].value}' \
          | tr -d [:space:])
for backup in $(seq 0 $(( "${BACKUPS}" - 1 )) ); do
  info "Uploading backup ${backup}"
  info ""
  kubectl cp "backup-${backup}.tar.gz" cassandra-restore:/tmp/backup.tar.gz --namespace "${NAMESPACE}"
  info "Restoring backup..."
  info ""
  kubectl exec -it cassandra-restore --namespace "${NAMESPACE}" -- /tmp/instance_restore.sh "${KEYSPACE}" "${SEEDS}"
done
info "Removing restore instance..."
info ""
kubectl delete -f "${SCRIPT_DIR}/controller.yaml" --namespace "${NAMESPACE}"
info ""

info "Done!"
