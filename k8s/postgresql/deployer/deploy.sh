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

name="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"

namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
if ! kubectl --namespace ${namespace} get secret | grep -q "^${name}-tls "; then
  file=/tmp/server
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout $file.key \
      -out $file.crt \
      -subj "/CN=postgresql/O=postgresql"
  
  kubectl --namespace ${namespace} create secret generic ${name}-tls \
      --from-file=$file.crt --from-file=$file.key
  rm $file.key
  rm $file.crt
fi

/bin/deploy-original.sh

application_uid=$(kubectl get applications/${name} --namespace=${namespace} --output=jsonpath='{.metadata.uid}')
kubectl patch secret ${name}-tls -p \
'
{
	"metadata": {
		"ownerReferences": [
			{
				"apiVersion":"app.k8s.io/v1beta1",
				"blockOwnerDeletion":true,
				"kind":"Application",
				"name":"'"${name}"'",
				"uid":"'"${application_uid}"'"
			}
		]
	}
}
'

NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"
NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"
export NAME
export NAMESPACE
/bin/clean_iam_resources-original.sh
