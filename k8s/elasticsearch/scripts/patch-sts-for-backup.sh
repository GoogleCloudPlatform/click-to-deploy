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
      echo "- app: ${app}"
      shift 2
      ;;
    --namespace)
      namespace="$2"
      echo "- namespace: ${namespace}"
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

if ! [[ -v backup_claim ]]; then
  backup_claim="${app}-backup"
  echo "Using default of ${backup_claim} for backup claim name..."
fi

readonly sts_name="${app}-elasticsearch"
readonly patch_manifest_file="/tmp/backup-sts-patch-expanded.yaml"

echo "Expanding patch manifest for Elasticsearch StatefulSet..."
export APP_INSTANCE_NAME="${app}"
export BACKUP_CLAIM_NAME="${backup_claim}"
cat scripts/backup-sts-patch.yaml \
  | envsubst '$BACKUP_CLAIM_NAME' \
  > "${patch_manifest_file}"

echo "Patching Stateful Set..."
kubectl patch statefulset "${sts_name}" \
  --namespace "${namespace}" \
  --patch "$(cat "${patch_manifest_file}")"

echo "Monitoring the rollout status..."
kubectl rollout status statefulset "${sts_name}" \
  --namespace "${namespace}"

echo "Restoring updateStrategy \"OnDelete\" for Elasticsearch StatefulSet..."
kubectl patch statefulset "${sts_name}" --namespace "${namespace}" \
  --patch '{ "spec": { "updateStrategy": {"type": "OnDelete" } } }'

echo "Done."
