#!/bin/bash

set -eo pipefail

export SCRIPT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

if [[ ! -f "${SCRIPT_DIR}/util.sh" ]]; then
  >&2 echo "Missing util.sh file, exiting"
  exit 1
fi

. "${SCRIPT_DIR}/util.sh"

if [[ -z "$1" ]]; then
  info "Please provide a keyspace"
  exit 1
fi

if [[ -z "$2" ]]; then
  info "Please provide a number of backup archives"
  exit 1
fi

KEYSPACE="$1"
BACKUPS="$2"
set -u

current_status
info "Preparing to restore a backup of keyspace '${KEYSPACE}' from ${BACKUPS} archieves"

wait_for_healthy_sts

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
