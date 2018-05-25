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
  --repo=*)
    repo="${i#*=}"
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

# Replace slashes with underscore in the name of the repo
keyname="$(echo $repo | tr / _ | tr '[:upper:]' '[:lower:]')"
ssh-keygen -t rsa -b 2048 -f $keyname -N '' -C "Deploy key for $repo"

bucket_path="$bucket/deploykeys/$keyname"
gsutil cp "$keyname" "$bucket_path"

rm $keyname

echo ""
echo "Private key $keyname added to $bucket_path."
echo ""
echo "Please add the public key $keyname.pub to the deploy keys of repository $repo."
