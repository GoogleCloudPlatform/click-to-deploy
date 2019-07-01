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

while [[ "$#" != 0 ]]; do
  case "$1" in
    --app)
      app="$2"
      echo "- app: $app"
      shift 2
      ;;
    --namespace)
      namespace="$2"
      echo "- namespace: ${namespace}"
      shift 2
      ;;
    --disk-size)
      disk_size="$2"
      echo "- disk size: ${disk_size}"
      shift 2
      ;;
    --backup-claim)
      backup_claim="$2"
      echo "- backup claim: ${backup_claim}"
      shift 2
      ;;
    *)
      echo "Unsupported flag: $1 - EXIT"
      exit 1
  esac
done;

# Check if all flags were provided:
for var in app namespace; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing required flag --${var} - EXIT"
    exit 1
  fi
done

if ! [[ -v disk_size ]]; then
  disk_size=2Gi
  echo "Using default of ${disk_size} for backup disk size..."

fi

if ! [[ -v backup_claim ]]; then
  backup_claim="${app}-backup"
  echo "Using default of ${backup_claim} for backup claim name..."
fi

echo "Expanding manifest templates for NFS server and shared disk..."
readonly nfs_manifest_file="/tmp/backup-nfs-expanded.yaml"
export APP_INSTANCE_NAME="${app}"
export BACKUP_DISK_SIZE="${disk_size}"
export BACKUP_CLAIM_NAME="${backup_claim}"
export NAMESPACE="${namespace}"
cat scripts/backup-nfs.yaml \
  | envsubst '$APP_INSTANCE_NAME $BACKUP_DISK_SIZE $BACKUP_CLAIM_NAME $NAMESPACE' \
  > "${nfs_manifest_file}"

echo "Creating NFS server and shared disk..."
kubectl apply -f "${nfs_manifest_file}" --namespace "${namespace}"

echo "Done."
