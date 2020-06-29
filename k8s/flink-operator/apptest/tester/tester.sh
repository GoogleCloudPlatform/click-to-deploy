#!/bin/bash
#
# Copyright 2020 Google LLC
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

set -euxo pipefail

until kubectl get deployments flink-operator-controller-manager -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' | grep True ; do sleep 1 ; done

export FLINK_JOB_CLUSTER_NAME="flink-job-cluster-${NAMESPACE}"
export FLINK_VERSION="flink:1.8.1"

cat flink-job-cluster.yaml

cat flink-job-cluster.yaml | envsubst | kubectl apply -f -
sleep 60
kubectl get pod -l app=flink,cluster=${FLINK_JOB_CLUSTER_NAME}

cat flink-job-cluster.yaml | envsubst | kubectl delete -f -
kubectl get services  -n ${NAMESPACE} | awk '/flink-operator/{print $1}' | xargs  kubectl delete -n ${NAMESPACE} service
kubectl get pods -n ${NAMESPACE} | awk '/flink-operator-controller-manager/{print $1}' | xargs kubectl delete -n ${NAMESPACE} pod
kubectl get deployments -n ${NAMESPACE} | awk '/flink-operator-controller-manager/{print $1}' | xargs kubectl delete -n ${NAMESPACE} deployment
