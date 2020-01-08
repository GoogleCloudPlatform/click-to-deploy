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

for test in /tests/common/*; do
  testrunner -logtostderr "--test_spec=${test}"
done

if [[ "${ENABLE_PUBLIC_SERVICE_AND_INGRESS}" == true ]]; then
  # Waits until Ingress is healthy.
  # TODO(wgrzelak): Remove this once
  # https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/pull/315 is
  # merged.
  until kubectl get ingress "${APP_INSTANCE_NAME}-wordpress-ingress" \
    --namespace "${NAMESPACE}" \
    --output jsonpath='{.metadata.annotations.ingress\.kubernetes\.io/backends}' \
    | jq -e '(.[] == "HEALTHY")'
  do
    sleep 3
  done

  export EXTERNAL_IP="$(kubectl get ingress ${APP_INSTANCE_NAME}-wordpress-ingress \
    --namespace ${NAMESPACE} \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')"

  for test in /tests/external/*; do
    testrunner -logtostderr "--test_spec=${test}"
  done
fi
