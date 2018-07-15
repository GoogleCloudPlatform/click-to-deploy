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

set -eu

if [[ -z "$1" ]]; then
  info "Please provide InfluxDB instance name"
  exit 1
fi

if [[ -z "$2" ]]; then
  NAMESPACE=default
else
  NAMESPACE=$2
fi

INFLUXDB_INSTANCE="$1"
INFLUXDB_BACKUP_DIR=influxdb-backup

echo "Connecting to InfluxDB instance and creating backup dirctory."
kubectl exec -it $INFLUXDB_INSTANCE-influxdb-0 --namespace "$NAMESPACE" -- mkdir /$INFLUXDB_BACKUP_DIR
echo "Connecting to InfluxDB instance and making a backup"
kubectl exec -it $INFLUXDB_INSTANCE-influxdb-0 --namespace "$NAMESPACE" -- influxd backup -portable /$INFLUXDB_BACKUP_DIR
echo "Creating backup directory on local computer"
mkdir $INFLUXDB_BACKUP_DIR
echo "Copying backup to local computer"
kubectl cp $INFLUXDB_INSTANCE-influxdb-0:/$INFLUXDB_BACKUP_DIR $INFLUXDB_BACKUP_DIR
