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

set -eu

. "/opt/spark/bin/load-spark-env.sh"

# Default values
: ${SPARK_ENABLE_HISTORY:=false}
: ${SPARK_ENABLE_PROMETHEUS:=false}

declare -r config_file="/opt/spark/conf/spark-defaults.conf"

# Configure Prometheus
if [[ "${SPARK_ENABLE_PROMETHEUS}" == "true" ]]; then
    cat <<EOF >> ${config_file}
spark.eventLog.logStageExecutorMetrics=true
spark.ui.prometheus.enabled=true
EOF
fi

# Configure History Server
if [[ "${SPARK_ENABLE_PROMETHEUS}" == "true" ]]; then
    mkdir -p /opt/spark-events
    cat <<EOF >> ${config_file}
spark.eventLog.enabled=true
spark.eventLog.dir=/opt/spark-events
spark.history.fs.logDirectory=/opt/spark-events
EOF
fi

cd /opt/spark/bin

if [ "${SPARK_WORKLOAD}" == "master" ]; then
    # Start master service
    export SPARK_MASTER_HOST=`hostname`
    ./spark-class org.apache.spark.deploy.master.Master \
        --host "${SPARK_MASTER_HOST}" \
        --port "${SPARK_MASTER_PORT}" \
        --webui-port ${SPARK_MASTER_WEBUI_PORT} >> ${SPARK_MASTER_LOG}
elif [ "${SPARK_WORKLOAD}" == "worker" ]; then
    # Start worker service
    ./spark-class org.apache.spark.deploy.worker.Worker \
        --webui-port ${SPARK_WORKER_WEBUI_PORT} ${SPARK_MASTER} >> ${SPARK_WORKER_LOG}
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, submit"
fi
