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

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout https1.key -out https1.cert

echo "HTTP Certicate"
cat https1.cert
echo "Base64 for Certificate"
cat https1.cert | base64 -w 0
echo ""
echo "Certificate Key"
cat https1.key
echo "Base64 for Certificate Key"
cat https1.key | base64 -w 0
echo ""
