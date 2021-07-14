#!/usr/bin/env bash

set -euo pipefail

if [ -n "${JAVA_OPTS}" ]; then
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [ -n "${LOGGING_LEVEL}" ]; then
    export JAVA_OPTS="-Dhazelcast.mc.log.level=${LOGGING_LEVEL} ${JAVA_OPTS}"
fi

if [ "${CONTAINER_SUPPORT:-true}" = "false" ] ;then
    echo "Container support disabled. Using manual heap sizing by specifying MIN_HEAP_SIZE, MAX_HEAP_SIZE or custom settings configured by JAVA_OPTS." 1>&2
    if [ -n "${MIN_HEAP_SIZE}" ]; then
        export JAVA_OPTS="${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}"
    fi
    if [ -n "${MAX_HEAP_SIZE}" ]; then
        export JAVA_OPTS="${JAVA_OPTS} -Xmx${MAX_HEAP_SIZE}"
    fi
else
    echo "Container support enabled. Using automatic heap sizing. JVM will use up to 80% of the memory limit of the container." 1>&2
    export JAVA_OPTS="${JAVA_OPTS} -XX:+UseContainerSupport -XX:MaxRAMPercentage=80"
fi

export MC_RUNTIME="${MC_HOME}/${MC_INSTALL_JAR}"
if [ -n "${MC_CLASSPATH}" ]; then
    export MC_CLASSPATH="${MC_RUNTIME}:${MC_CLASSPATH}"
else
    export MC_CLASSPATH="${MC_RUNTIME}"
fi

if [ -n "${MC_INIT_CMD}" ]; then
   echo "Executing command specified by MC_INIT_CMD for container initialization." 1>&2
   eval "${MC_INIT_CMD}"
fi

if [ -n "${MC_INIT_SCRIPT}" ]; then
    echo "Loading script $MC_INIT_SCRIPT specified by MC_INIT_SCRIPT for container initialization." 1>&2
    # shellcheck source=/dev/null
    source "${MC_INIT_SCRIPT}"
fi

if [ -n "${MC_ADMIN_USER}" ] && [ -n "${MC_ADMIN_PASSWORD}" ]; then
  echo "Creating admin user."  1>&2
  source ./bin/mc-conf.sh user create --lenient=true -n="${MC_ADMIN_USER}" -p="${MC_ADMIN_PASSWORD}" -r=admin
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo "User created successfully." 1>&2
  else
    exit 1
  fi
fi

echo "##################################################" 1>&2
echo "# Initialisation complete, starting now....      #" 1>&2
echo "##################################################" 1>&2

# --add-opens flag is required to prevent this issue: https://jira.spring.io/browse/SPR-15859
set -x
# shellcheck disable=SC2086
exec java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -server ${JAVA_OPTS} \
    -cp "${MC_CLASSPATH}" \
    -Dhazelcast.mc.contextPath=${MC_CONTEXT_PATH} \
    -Dhazelcast.mc.http.port=${MC_HTTP_PORT} \
    -Dhazelcast.mc.https.port=${MC_HTTPS_PORT} \
    com.hazelcast.webmonitor.Launcher
