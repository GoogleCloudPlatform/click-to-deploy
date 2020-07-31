#!/usr/bin/env bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The zkMetrics script can be used to retrieve metrics from the ZooKeeper
# process and print them to stdout. A recurring Kubernetes job can be used
# to collect these metrics and provide them to a collector.

set -eu

ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-2181}
echo mntr | nc localhost $ZK_CLIENT_PORT >& 1
