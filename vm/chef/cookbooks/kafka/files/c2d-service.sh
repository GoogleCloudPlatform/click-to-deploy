#!/bin/bash
#
# Copyright 2022 Google Inc.
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

start() {
  set -x

  # Start services
  if [[ -f /opt/kafka/config/zookeeper_jaas.conf ]]; then
    export KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/zookeeper_jaas.conf"
  fi
  /opt/kafka/bin/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties

  sleep 10
  export KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/kafka_server_jaas.conf"
  /opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties
}

stop(){
  /opt/kafka/bin/kafka-server-stop.sh /opt/kafka/config/server.properties
  /opt/kafka/bin/zookeeper-server-stop.sh /opt/kafka/config/zookeeper.properties
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
esac
