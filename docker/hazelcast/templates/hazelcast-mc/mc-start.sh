#!/usr/bin/env bash

# Enable bash debug if DEBUG_DOCKER_ENTRYPOINT exists.
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi

set -euo pipefail
if [[ -n "${JAVA_OPTS}" ]]; then
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [[ -n "${MIN_HEAP_SIZE}" ]]; then
    export JAVA_OPTS="${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}"
fi

if [[ -n "${MAX_HEAP_SIZE}" ]]; then
    export JAVA_OPTS="${JAVA_OPTS} -Xmx${MAX_HEAP_SIZE}"
fi

if [[ -n "${MC_CLASSPATH}" ]]; then
    export MC_CLASSPATH="${MC_RUNTIME}:${MC_CLASSPATH}"
else
    export MC_CLASSPATH="${MC_RUNTIME}"
fi

if [[ -n "${MC_INIT_CMD}" ]]; then
   echo "executing command specified by MC_INIT_CMD"
   eval "${MC_INIT_CMD}"
fi

if [[ -n "${MC_INIT_SCRIPT}" ]]; then
   echo "loading script $MC_INIT_SCRIPT specified by MC_INIT_SCRIPT"
   source ${MC_INIT_SCRIPT}
fi

echo "########################################"
echo "# JAVA_OPTS=${JAVA_OPTS}"
echo "# MC_CLASSPATH=${MC_CLASSPATH}"
echo "# starting now...."
echo "########################################"

# --add-opens flag is required to prevent this issue: https://jira.spring.io/browse/SPR-15859
set -x
exec java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -server ${JAVA_OPTS} \
    -cp "${MC_CLASSPATH}" \
    Launcher \
    ${MC_HTTP_PORT} \
    ${MC_HTTPS_PORT} \
    ${MC_CONTEXT}
