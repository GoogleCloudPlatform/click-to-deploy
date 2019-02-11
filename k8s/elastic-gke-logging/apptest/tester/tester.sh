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

export ELASTIC_URL="http://${APP_INSTANCE_NAME}-elasticsearch-svc:9200"
export HEALTH_URL="${ELASTIC_URL}/_cluster/health"

export KIBANA_URL="http://${APP_INSTANCE_NAME}-kibana-svc:5601"
export KIBANA_FIND_URL="${KIBANA_URL}/api/saved_objects/_find"

function find_kibana_object() {
  local search_type="$1"
  local search_title="$2"
  search_url="${KIBANA_FIND_URL}?type=${search_type}&search_fields=title&search=${search_title// /%20}"
  curl -s "${search_url}"
}

function find_saved_kibana_search_count() {
  local search_title="$1"
  local total="$(find_kibana_object 'search' "${search_title}" | jq '.total')"
  if [[ ${total} -eq 1 ]]; then
    echo "OK - ${search_title} search found once"
  else
    echo "FAIL - ${search_title} searches found: ${total}"
  fi
}

function find_saved_kibana_index_pattern_count() {
  local search_title="$1"
  local total="$(find_kibana_object 'index-pattern' "${search_title}" | jq '.total')"
  if [[ ${total} -eq 1 ]]; then
    echo "OK - ${search_title} index pattern found once"
  else
    echo "FAIL - ${search_title} index patterns found: ${total}"
  fi
}

export -f find_kibana_object
export -f find_saved_kibana_search_count
export -f find_saved_kibana_index_pattern_count

for test in /tests/*; do
  testrunner -logtostderr "--test_spec=${test}"
done
