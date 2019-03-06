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

set -eox pipefail

# Non-standard deployer entrypoint.
# This steps are needed to interfere with deployer - add new resource programmatically
# before dropping IAM permissions.

NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"
NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"
export NAME
export NAMESPACE

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=wordpress/O=wordpress"

kubectl --namespace ${NAMESPACE} create secret tls ${NAME}-tls \
    --cert=/tmp/tls.crt --key=/tmp/tls.key

kubectl --namespace ${NAMESPACE} label secret ${NAME}-tls \
    "app.kubernetes.io/name=${NAME}" "app.kubernetes.io/component=wordpress-tls"

/bin/deploy-original.sh

APPLICATION_UID=$(kubectl get applications/${NAME} --namespace=${NAMESPACE} --output=jsonpath='{.metadata.uid}')
kubectl --namespace=${NAMESPACE} patch secret ${NAME}-tls -p \
'
{
  "metadata": {
    "ownerReferences": [
      {
        "apiVersion":"app.k8s.io/v1beta1",
        "blockOwnerDeletion":true,
        "kind":"Application",
        "name":"'"${NAME}"'",
        "uid":"'"${APPLICATION_UID}"'"
      }
    ]
  }
}
'

/bin/clean_iam_resources-original.sh
