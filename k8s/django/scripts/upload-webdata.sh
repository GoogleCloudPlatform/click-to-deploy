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

if [[ -z "$NAMESPACE" ]]; then
  echo "Define NAMESPACE environment variable!"
  exit 1
fi

if [[ -z "$APP_INSTANCE_NAME" ]]; then
  echo "Define APP_INSTANCE_NAME environment variable!"
  exit 1
fi

PODS=$(kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace $NAMESPACE | awk 'FNR>1 {print $1}')

TIMEOUT=60

echo "Performing upload of content to NGINX server instances..."

for i in ${PODS[@]}; do
  echo "- uploading data to $i Pod"
  kubectl cp html $i:/usr/share/nginx
  kubectl exec $i -- chmod -R a+r /usr/share/nginx/html
done

echo "Upload operation finished."
