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
  --githubapp=*)
    githubapp="${i#*=}"
    shift
    ;;
  --keyfile=*)
    keyfile="${i#*=}"
    shift
    ;;
  --bucket=*)
    bucket="${i#*=}"
    shift
    ;;
  *)
    >&2 echo "Unrecognized flag: $i"
    exit 1
    ;;
esac
done

# Replace slashes with underscore in the name of the app
keyname="$(echo $githubapp | tr / _ | tr '[:upper:]' '[:lower:]')"

bucket_path="$bucket/appkeys/$keyname"
echo "$keyfile"
gsutil cp "$keyfile" "$bucket_path"

echo ""
echo "Private key $keyname added to $bucket_path."
echo ""
echo "Remove the private key."
