# Copyright 2020 Google LLC
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

FROM gcr.io/google-appengine/debian9:latest

ENV DEBUG_DOCKER_ENTRYPOINT false

ENV HAZELCAST_VERSION 3.12.4
ENV C2D_RELEASE 3.12.4

# Versions of Hazelcast and Hazelcast plugins
ARG HZ_VERSION=3.12.4
ARG HZ_VERSION_SHA=b3f6c41142dbdbd9f98a72808364234fcc1c4539
ARG CACHE_API_VERSION=1.1.1
ARG CACHE_API_VERSION_SHA=c56fb980eb5208bfee29a9a5b9d951aba076bd91
ARG HZ_EUREKA_VERSION=1.1.1
ARG JMX_PROMETHEUS_AGENT_VERSION=0.11.0

# Build constants
ARG HZ_HOME="/opt/hazelcast"
ARG HZ_JAR="hazelcast-all-${HZ_VERSION}.jar"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"

# Runtime constants / variables
ENV HZ_HOME="${HZ_HOME}" \
    CLASSPATH_DEFAULT="${HZ_HOME}/*:${HZ_HOME}/lib/*" \
    JAVA_OPTS_DEFAULT="-Djava.net.preferIPv4Stack=true -Djava.util.logging.config.file=${HZ_HOME}/logging.properties" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    MANCENTER_URL="" \
    PROMETHEUS_PORT="" \
    PROMETHEUS_CONFIG="${HZ_HOME}/jmx_agent_config.yaml" \
    LOGGING_LEVEL="" \
    CLASSPATH="" \
    JAVA_OPTS=""

# Expose port
EXPOSE 5701

COPY *.xml *.sh *.yaml *.properties ${HZ_HOME}/

# Install
RUN set -e; \
    apt-get update \
    && apt-get -y install \
    openjdk-8-jre \
    maven \
    bash \
    curl \
    procps \
    net-tools \
    telnet \
    inetutils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Installing Hazelcast" \
    && cd "${HZ_HOME}" \
    && mkdir lib \
    && curl -sf -o ${HZ_HOME}/lib/${HZ_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/hazelcast-all/${HZ_VERSION}/${HZ_JAR} \
    && echo ${HZ_VERSION_SHA} ${HZ_HOME}/lib/${HZ_JAR} | sha1sum -c

RUN echo "Installing JCache" \
    && curl -sf -o "${HZ_HOME}/lib/${CACHE_API_JAR}" \
         -L "https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/${CACHE_API_JAR}" \
    && echo ${CACHE_API_VERSION_SHA} ${HZ_HOME}/lib/${CACHE_API_JAR} | sha1sum -c

RUN echo "Installing Hazelcast plugins" \
    && mvn -f "${HZ_HOME}/dependency-copy.xml" \
           -Dhazelcast-eureka-version="${HZ_EUREKA_VERSION}" \
           dependency:copy-dependencies

RUN echo "Maven clean-up" \
    && apt remove -fy maven \
    && rm -rf ~/.m2 \
    && rm -f dependency-copy.xml

RUN echo "Installing JMX Prometheus Agent" \
    && curl -sf -o "${HZ_HOME}/lib/jmx_prometheus_javaagent.jar" \
         -L "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_AGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_AGENT_VERSION}.jar" \
    && echo "Granting read permission to ${HZ_HOME}" \
    && chmod -R +r "${HZ_HOME}" \
    && echo "Setting Pardot ID to 'docker'" \
    && echo 'hazelcastDownloadId=docker' > hazelcast-download.properties \
    && echo "Cleaning APT packages" \
    && apt clean

RUN echo "Adding license to /usr/share/hazelcast directory" \
    && mkdir -p /usr/share/hazelcast/ \
    && curl https://raw.githubusercontent.com/hazelcast/hazelcast/master/LICENSE -o /usr/share/hazelcast/LICENSE

WORKDIR ${HZ_HOME}

# Start Hazelcast server
CMD ["/opt/hazelcast/start-hazelcast.sh"]
