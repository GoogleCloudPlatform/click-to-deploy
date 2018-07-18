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

set -eu

KEYSPACE=$1
SEEDS=$2

mkdir -p "/tmp/${KEYSPACE}"
mkdir -p /tmp/backup
tar -zxf /tmp/backup.tar.gz -C /tmp/backup

for table in $(ls /tmp/backup); do
  timestamp=$(ls "/tmp/backup/${table}")
  mkdir -p "/tmp/${KEYSPACE}/${table}"
  mv /tmp/backup/${table}/${timestamp}/* "/tmp/$KEYSPACE/$table/"
  sstableloader -d "${SEEDS}" "/tmp/${KEYSPACE}/${table}"
  rm -rf "/tmp/${KEYSPACE}/${table}"
done

rm -rf /tmp/backup
rm -rf "/tmp/${KEYSPACE}"
rm -rf /tmp/backup.tar.gz
