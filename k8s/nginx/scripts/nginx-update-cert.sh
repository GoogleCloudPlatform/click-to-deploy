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

CERT_FILE=https1.cert
KEY_FILE=https1.key

if [[ -z "$NAMESPACE" ]]; then
  echo "Define NAMESPACE environment variable!"
  exit 1
fi

if [[ -z "$APP_INSTANCE_NAME" ]]; then
  echo "Define APP_INSTANCE_NAME environment variable!"
  exit 1
fi

if [[ -f $CERT_FILE ]]; then
  echo "Using $CERT_FILE as a certificate."
else
  echo "File $CERT_FILE doesn't exist. Run nginx-create-key.sh script"
  exit 1
fi

if [[ -f $KEY_FILE ]]; then
  echo "Using $KEY_FILE as a certificate."
else
  echo "File $KEY_FILE doesn't exist. Run nginx-create-key.sh script"
  exit 1
fi

# using --dry-run and then using kubectl apply... to avoid errors
# while invoking kubectl create for the secret that already exist
kubectl --namespace $NAMESPACE create secret generic $APP_INSTANCE_NAME-nginx-secret \
	--from-file=$CERT_FILE --from-file=$KEY_FILE \
	--dry-run -o yaml | kubectl apply -f -

PODS=$(kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace $NAMESPACE | awk 'FNR>1 {print $1}')

TIMEOUT=60

for i in ${PODS[@]}; do
  echo "Deleting Pod: $i..."
  kubectl delete pod $i --namespace $NAMESPACE
  echo "Sleeping for $TIMEOUT seconds..."
  sleep $TIMEOUT
done
