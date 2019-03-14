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


NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"

NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"

export NAME
export NAMESPACE

[[ -z "$NAME" ]] && echo "NAME must be set" && exit 1
[[ -z "$NAMESPACE" ]] && echo "NAMESPACE must be set" && exit 1

# We need to install the webhooks which cannot be installed by deploy.sh due to
# cluster-admin permissions. Unfortunately Agones controller will have already
# have been created, referencing certificates that will not be valid.

# At this stage there are also no CRDs available to Agones, so we temporarily
# shutdown the controller so we can fix all of this:

kubectl --namespace=${NAMESPACE} scale deployment agones-controller --replicas=0 --timeout=5m

ready_replicas=$(kubectl get deployment --namespace=${NAMESPACE} agones-controller -o jsonpath="{.status.readyReplicas}")
while [[ ${ready_replicas} -gt 0 ]] ; do
  echo Waiting for agones-controller to scale down...
  sleep 1
  ready_replicas=$(kubectl get deployment --namespace=${NAMESPACE} agones-controller -o jsonpath="{.status.readyReplicas}")
done

# Recreate the manifests
# [begin snippet from deploy.sh]
app_uid=$(kubectl get "applications/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.metadata.uid}')
app_api_version=$(kubectl get "applications/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.apiVersion}')

/bin/expand_config.py --values_mode raw --app_uid "$app_uid"

/bin/create_manifests.sh
# [end snippet from deploy.sh]

# Modify helm values to include CRDs and Webhooks
sed -i'' 's/registerWebhooks: false/registerWebhooks: true/' /data/extracted/chart/chart/values.yaml
sed -i'' 's/install: false/install: true/' /data/extracted/chart/chart/values.yaml

# Regenerate manifest required entries
helm template "/data/extracted/chart/chart" \
  --name="$NAME" \
  --namespace="$NAMESPACE" \
  --values=<(/bin/print_config.py --output=yaml) \
  -x "charts/agones/templates/admissionregistration.yaml" \
  -x "charts/agones/templates/controller.yaml" \
  `tar ztf /data/extracted/chart/chart/charts/agones-*.tgz | grep /crds/ | grep -v /_ | awk -F'\n' '{printf "-x charts/"$0" "}'` \
  > "/data/stage2-raw.yaml"

# Re-apply ownership metadata
/bin/set_ownership.py \
  --app_name "$NAME" \
  --app_uid "$app_uid" \
  --app_api_version "$app_api_version" \
  --noapp \
  --manifests "/data/stage2-raw.yaml" \
  --dest "/data/stage2.yaml"

# Apply delta to fix installation
kubectl apply -f /data/stage2.yaml
