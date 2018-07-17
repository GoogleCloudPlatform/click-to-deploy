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

if [[ -z "$NAMESPACE" ]]; then
  echo "Define NAMESPACE environment variable!"
  exit 1
fi

if [[ -z "$APP_INSTANCE_NAME" ]]; then
  echo "Define APP_INSTANCE_NAME environment variable!"
  exit 1
fi

echo "Performing backup of NGINX server content from the first Pod..."
echo "- Connecting to $APP_INSTANCE_NAME-nginx-0 Pod"
mkdir -p backup
kubectl cp --namespace $NAMESPACE $APP_INSTANCE_NAME-nginx-0:/usr/share/nginx/html backup
echo "Backup operation finished."
