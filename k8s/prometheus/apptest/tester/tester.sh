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

export PROMETHEUS_URL="http://${APP_INSTANCE_NAME}-prometheus:9090"

export GRAFANA_URL="http://${GRAFANA_USERNAME}:${GRAFANA_PASSWORD}@${APP_INSTANCE_NAME}-grafana"
export GRAFANA_SEARCH_API_URL="${GRAFANA_URL}/api/search"

function search_grafana_dash_db() {
  local query="$1"
  # Replace spaces in query with HTML code %20
  curl -s "${GRAFANA_SEARCH_API_URL}?type=dash-db&query=${query// /%20}"
}

export -f search_grafana_dash_db

for test in /tests/*; do
  testrunner -logtostderr "--test_spec=${test}"
done
