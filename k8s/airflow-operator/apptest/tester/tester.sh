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

export NAME="airflow-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
export BASE_YAML=airflowbase.yaml
export CLUSTER_YAML=airflowcluster.yaml

cat airflowcluster.yaml | envsubst > ${CLUSTER_YAML}
cat airflowbase.yaml | envsubst > ${BASE_YAML}

cat ${BASE_YAML}
cat ${CLUSTER_YAML}

kubectl apply -f ${BASE_YAML}
sleep 60
kubectl apply -f ${CLUSTER_YAML}
sleep 60
kubectl get -f ${BASE_YAML} -o yaml
kubectl get -f ${CLUSTER_YAML} -o yaml
kubectl delete -f ${BASE_YAML}
kubectl delete -f ${CLUSTER_YAML}
