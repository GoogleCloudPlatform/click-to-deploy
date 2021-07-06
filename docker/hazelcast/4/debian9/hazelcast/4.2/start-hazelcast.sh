#!/bin/bash

set -euo pipefail

# Enable bash debug if DEBUG_DOCKER_ENTRYPOINT exists.
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi

eval JAVA_OPTS=\"${JAVA_OPTS}\"
eval CLASSPATH=\"${CLASSPATH}\"

if [[ -n "${CLASSPATH}" ]]; then
  export CLASSPATH="${CLASSPATH_DEFAULT}:${CLASSPATH}"
else
  export CLASSPATH="${CLASSPATH_DEFAULT}"
fi

if [[ -n "${JAVA_OPTS}" ]]; then
  export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
  export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [[ -n "${MIN_HEAP_SIZE}" ]]; then
  export JAVA_OPTS="-Xms${MIN_HEAP_SIZE} ${JAVA_OPTS}"
fi

if [[ -n "${MAX_HEAP_SIZE}" ]]; then
  export JAVA_OPTS="-Xmx${MAX_HEAP_SIZE} ${JAVA_OPTS}"
fi

if [[ -n "${MANCENTER_URL}" ]]; then
  export JAVA_OPTS="-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=${MANCENTER_URL} ${JAVA_OPTS}"
else
  export JAVA_OPTS="-Dhazelcast.mancenter.enabled=false ${JAVA_OPTS}"
fi

if [[ -n "${PROMETHEUS_PORT}" ]]; then
  export JAVA_OPTS="-javaagent:${HZ_HOME}/lib/jmx_prometheus_javaagent.jar=${PROMETHEUS_PORT}:${PROMETHEUS_CONFIG} ${JAVA_OPTS}"
fi

if [[ -n "${LOGGING_LEVEL}" ]]; then
  sed -i "s/java.util.logging.ConsoleHandler.level = INFO/java.util.logging.ConsoleHandler.level = ${LOGGING_LEVEL}/g" logging.properties
  sed -i "s/.level= INFO/.level= ${LOGGING_LEVEL}/g" logging.properties
fi

echo "########################################"
echo "# JAVA_OPTS=${JAVA_OPTS}"
echo "# CLASSPATH=${CLASSPATH}"
echo "# starting now...."
echo "########################################"
set -x
exec java -server ${JAVA_OPTS} com.hazelcast.core.server.StartServer
