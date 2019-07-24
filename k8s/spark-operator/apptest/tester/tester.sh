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

set -eo pipefail

export SPARK_APP_NAME="spark-$(uuidgen)"
cat spark-pi.yaml.template | envsubst > spark-pi.yaml

cat spark-pi.yaml

kubectl apply -f spark-pi.yaml

while true; do
  echo "Retrieving events"
  events=$(kubectl get events -o=json | \
    jq ".items[] | select(.involvedObject.name==\"$SPARK_APP_NAME\" and .involvedObject.namespace==\"$NAMESPACE\") | .reason")
  
  echo $events

  echo "Checking events for completed status"
  completed_status=$(echo $events | grep "SparkApplicationCompleted" || true)
  if [[ -n "$completed_status" ]]; then
    echo "Delete sparkapplication $SPARK_APP_NAME"
    kubectl delete sparkapplication "$SPARK_APP_NAME"
    exit 0
  fi

  echo "Checking events for failed status"
  failed_status=$(echo $events | grep "SparkApplicationFailed" || true)
  if [[ -n "$failed_status" ]]; then
    echo "Delete sparkapplication $SPARK_APP_NAME"
    kubectl delete sparkapplication "$SPARK_APP_NAME"
    exit 1
  fi

  echo "Waiting 4 seconds before retry"
  sleep 4
done
