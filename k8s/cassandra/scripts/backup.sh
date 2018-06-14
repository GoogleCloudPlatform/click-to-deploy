#!/bin/bash

if [[ ! -f scripts/util.sh ]]; then
  >&2 echo "Missing util.sh file, exiting"
  exit 1
fi

. scripts/util.sh

if [[ -z "${1}" ]]; then
  info "Please provide a keyspace"
  exit 1
fi

KEYSPACE="${1}"

function upload_backup_script_cmd {
  for i in $(seq 0 $(( "${1}" - 1 )) ); do
    echo "kubectl cp scripts/make_backup.sh ${APP_INSTANCE_NAME}-cassandra-${i}:/make_backup.sh -n $NAMESPACE"
  done
}

function backup_containers_cmd {
  for i in $(seq 0 $(( "${1}" - 1 )) ); do
    echo "kubectl exec ${APP_INSTANCE_NAME}-cassandra-${i} -n $NAMESPACE -- /make_backup.sh ${2}"
  done
}

function get_backups_containers_cmd {
  for i in $(seq 0 $(( "${1}" - 1 )) ); do
    echo "kubectl cp ${APP_INSTANCE_NAME}-cassandra-${i}:/tmp/backup.tar.gz backup-${i}.tar.gz -n $NAMESPACE"
  done
}

function delete_files_from_containers_cmd {
  for i in $(seq 0 $(( "${1}" - 1 )) ); do
    for j in "/make_backup.sh" "/tmp/backup.tar.gz" "/tmp/backup"; do
      echo "kubectl exec ${APP_INSTANCE_NAME}-cassandra-${i} -n $NAMESPACE -- rm -rf ${j}"
    done
  done
}

$(current_status)
info "Preparing to make a backup of keyspace '$KEYSPACE'"

$(wait_for_healthy_sts)

COUNT=$(get_desired_number_of_replicas_in_sts)

info "Performing backup of $COUNT containers"

info "Uploading backup script"
upload_backup_script_cmd "${COUNT}" | parallel
if [[ $? -ne 0 ]]; then
  info "Cannot upload backup script"
  exit 1
fi

info "Running backup script"
backup_containers_cmd "${COUNT}" "${KEYSPACE}" | parallel
STATUS=$?
if [[ $STATUS -ne 0 ]]; then
  info "Backup failed, $STATUS failed of $COUNT backub jobs"
  NEW_COUNT=$(get_desired_number_of_replicas_in_sts)
  if [[ $COUNT -ne $NEW_COUNT ]]; then
    info "Number of containers has changed from $COUNT to $NEW_COUNT"
  fi
  exit 1
fi

info ""
info "Downloading backups"
info ""
get_backups_containers_cmd "${COUNT}" | parallel
if [[ $? -ne 0 ]]; then
  info "Downloading backups failed"
  exit 1
fi
info "Backup is successful"
info ""
info "Removing files from pods"
info ""
delete_files_from_containers_cmd "${COUNT}" | parallel
if [[ $? -ne 0 ]]; then
  info "Removing failed"
  exit 1
fi


info "Getting schema..."
info ""
kubectl exec -it ${APP_INSTANCE_NAME}-cassandra-0 -n $NAMESPACE -c cassandra -- cqlsh -e "DESC KEYSPACE ${KEYSPACE}" > backup-schema.cql

info "Getting ring info..."
info ""
kubectl exec -it ${APP_INSTANCE_NAME}-cassandra-0 -n $NAMESPACE -c cassandra -- nodetool ring > backup-ring.info

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
