#!/bin/bash
#
# Copyright 2021 Google LLC
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

set -e

# Clear some variables that we don't want runtime
unset KAFKA_USER KAFKA_UID KAFKA_GROUP KAFKA_GID \
      KAFKA_DOCKER_SCRIPTS KAFKA_DIST_URL KAFKA_SHA512

if [[ "$VERBOSE" == "yes" ]]; then
    set -x
fi

if [[ -v KAFKA_PORT ]] && ! grep -E -q '^[0-9]+$' <<<"${KAFKA_PORT:-}"; then
  KAFKA_PORT=9092
  export KAFKA_PORT
fi

# when invoked with e.g.: docker run kafka -help
if [ "${1:0:1}" == '-' ]; then
    set -- "$KAFKA_HOME/bin/kafka-server-start.sh" "$@"
fi

# execute command passed in as arguments.
# The Dockerfile has specified the PATH to include
# /opt/kafka/bin (for kafka) and /opt/docker-kafka/scripts (for our scripts
# like create-topics, start-kafka, versions).
exec "$@"
