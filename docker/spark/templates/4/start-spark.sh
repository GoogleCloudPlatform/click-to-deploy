#!/bin/bash
#
# Copyright 2022 Google LLC
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

. "/opt/spark/bin/load-spark-env.sh"

# Default values
export SPARK_MASTER_HOST=`hostname`
export SPARK_LOCAL_IP="${SPARK_LOCAL_IP:=$(hostname)}"
export SPARK_ENABLE_HISTORY="${SPARK_ENABLE_HISTORY:=false}"
export SPARK_ENABLE_PROMETHEUS="${SPARK_ENABLE_PROMETHEUS:=false}"
export START_MASTER="${START_MASTER:=false}"
export START_WORKER="${START_WORKER:=false}"
export START_HISTORY="${START_HISTORY:=false}"

declare -r config_file="/opt/spark/conf/spark-defaults.conf"

# Enable bash debug if DEBUG_DOCKER_ENTRYPOINT exists
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
  echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
  echo "!!! WARNING: Use only for debugging. Do not use in production!"
  set -x
  env
fi

function setup_prometheus() {
  cat <<EOF >> ${config_file}
spark.eventLog.logStageExecutorMetrics=true
spark.ui.prometheus.enabled=true
EOF
}

function setup_history_server() {
  mkdir -p /opt/spark-events
  cat <<EOF >> ${config_file}
spark.eventLog.enabled=true
spark.eventLog.dir=/opt/spark-events
spark.history.fs.logDirectory=/opt/spark-events
EOF
}

# Configure Prometheus
if [[ "${SPARK_ENABLE_PROMETHEUS}" == "true" ]]; then
  setup_prometheus
fi

# Configure History Server
if [[ "${SPARK_ENABLE_HISTORY}" == "true" ]]; then
  setup_history_server
fi

if [[ "${SPARK_WORKLOAD}" == "master" ]]; then
  # Start master service
  export START_MASTER="true"
  if [[ "${SPARK_ENABLE_HISTORY}" == "true" ]]; then
    export START_HISTORY="true"
  fi
elif [[ "${SPARK_WORKLOAD}" == "worker" ]]; then
    # Start worker service
    export START_WORKER="true"
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker or history."
fi

# Start supervisor
supervisord --nodaemon --configuration /etc/supervisor/conf.d/supervisor.conf
