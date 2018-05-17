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

set -eo pipefail

for i in "$@"
do
case $i in
  --secret=*)
    secret="${i#*=}"
    shift
    ;;
  --issuer=*)
    issuer="${i#*=}"
    shift
    ;;
  --commit=*)
    commit="${i#*=}"
    shift
    ;;
  --repo=*)
    repo="${i#*=}"
    shift
    ;;
  --state=*)
    state="${i#*=}"
    shift
    ;;
  --description=*)
    description="${i#*=}"
    shift
    ;;
  --context=*)
    context="${i#*=}"
    shift
    ;;
  --target_url=*)
    target_url="${i#*=}"
    shift
    ;;
  *)
    >&2 echo "Unrecognized flag: $i"
    exit 1
    ;;
esac
done

# Getting the directory of the running script
DIR="$(realpath $(dirname $0))"

jwt_token="$($DIR/get_jwt.py --secret "$secret" --issuer " $issuer")"

accept_header="Accept: application/vnd.github.machine-man-preview+json"
auth_header="Authorization: Bearer $jwt_token"

install_id=$(curl -X GET https://api.github.com/app/installations \
-H "$accept_header" \
-H "$auth_header" | jq -r '.[0].id')

token=$(curl -X POST "https://api.github.com/installations/$install_id/access_tokens" \
-H "$accept_header" \
-H "$auth_header" | jq -r '.token')

token_header="Authorization: Bearer $token"

curl -X POST "https://api.github.com/repos/$repo/statuses/$commit" \
-H "$accept_header" \
-H "$token_header" \
-d @- <<EOF
{
  "state": "$state",
  "target_url": "$target_url",
  "description": "$description",
  "context": "$context"
}
EOF
