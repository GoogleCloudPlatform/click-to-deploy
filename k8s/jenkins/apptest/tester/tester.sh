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

set -xeo pipefail
shopt -s nullglob

SERVICE="${APP_INSTANCE_NAME}-jenkins-ui"

IP=$(kubectl get service "${SERVICE}" \
  --namespace "${NAMESPACE}" \
  -ojsonpath="{.spec.clusterIP}")

PORT=$(kubectl get service "${SERVICE}" \
  --namespace "${NAMESPACE}" \
  -ojsonpath="{.spec.ports[0].port}")

POD=$(kubectl get pod -oname \
  --namespace "${NAMESPACE}" | \
  sed -n "/\\/${APP_INSTANCE_NAME}-jenkins/s.pods\\?/..p")

PASSWORD=$(kubectl exec "${POD}" \
  --namespace "${NAMESPACE}" \
  cat /var/jenkins_home/secrets/initialAdminPassword)

export IP
export PORT
export PASSWORD

for test in /tests/*; do
  testrunner -logtostderr "--test_spec=${test}"
done
