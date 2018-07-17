#!/bin/bash
#
# Copyright 2018 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [[ -z "$1" ]]; then
  info "Please, provide InfluxDB instance name"
  info "Invoke make_restore.sh script in the following way:"
  info "make_restore.sh <app instance name> <namespace> <backup folder>"
  exit 1
fi

if [[ -z "$2" ]]; then
  info "Please, provide Kubernetes namespace to use"
  info "Invoke make_restore.sh script in the following way:"
  info "make_restore.sh <app instance name> <namespace> <backup folder>"
  exit 1
fi

if [[ -z "$3" ]]; then
  info "Please, provide folder for backup"
  info "Invoke make_restore.sh script in the following way:"
  info "make_restore.sh <app instance name> <namespace> <backup folder>"
  exit 1
fi


INFLUXDB_INSTANCE="$1"
NAMESPACE="$2"
INFLUXDB_BACKUP_DIR="$3"

echo "Connecting to the following InfluxDB: $INFLUXDB_INSTANCE..."

echo "Creating restore directory..."
kubectl exec $INFLUXDB_INSTANCE-influxdb-0 --namespace "$NAMESPACE" -- mkdir -p /$INFLUXDB_BACKUP_DIR
echo "- Copying backup to local computer"
kubectl cp $INFLUXDB_BACKUP_DIR $INFLUXDB_INSTANCE-influxdb-0:/$INFLUXDB_BACKUP_DIR
echo "- Connecting to InfluxDB instance and performing restore operation"
kubectl exec $INFLUXDB_INSTANCE-influxdb-0 --namespace "$NAMESPACE" -- influxd restore -portable /$INFLUXDB_BACKUP_DIR/$INFLUXDB_BACKUP_DIR
echo "- Removing temporary backup files from $INFLUXDB_INSTANCE-influxdb-0 Pod"
kubectl exec -it $INFLUXDB_INSTANCE-influxdb-0 --namespace "$NAMESPACE" -- rmdir -rf /$INFLUXDB_BACKUP_DIR
echo "Restore operation finished."
