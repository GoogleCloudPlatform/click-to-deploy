# Copyright 2021 Google LLC
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

FROM marketplace.gcr.io/google/debian10

ENV DEBUG_DOCKER_ENTRYPOINT false

ENV HAZELCAST_VERSION 4.2.4
ENV C2D_RELEASE 4.2.4

# Versions of Hazelcast and Hazelcast plugins
ARG HZ_VERSION=4.2.4
ARG HZ_VERSION_SHA=ec41b0181341e311e4d68f12dee5b700650d1f158858c1a44bae5ad0e686eb2e
ARG CACHE_API_VERSION=1.1.1
ARG JMX_PROMETHEUS_AGENT_VERSION=0.14.0
ARG LOG4J2_VERSION=2.17.0

# Build constants
ARG HZ_HOME="/opt/hazelcast"

# JARs to download
ARG HAZELCAST_ALL_URL="https://repo1.maven.org/maven2/com/hazelcast/hazelcast-all/${HZ_VERSION}/hazelcast-all-${HZ_VERSION}.jar"
ARG CACHE_API_URL="https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/cache-api-${CACHE_API_VERSION}.jar"
ARG PROMETHEUS_AGENT_URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_AGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_AGENT_VERSION}.jar"
ARG LOG4J2_URLS="https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/${LOG4J2_VERSION}/log4j-core-${LOG4J2_VERSION}.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/${LOG4J2_VERSION}/log4j-api-${LOG4J2_VERSION}.jar"

# If you update Eureka plugin version, please update also all its dependencies
# You can fetch Eureka plugin dependencies with `mvn dependency:list -DincludeScope=runtime -DoutputAbsoluteArtifactFilename=true` executed at https://github.com/hazelcast/hazelcast-eureka
# For the already formatted output, use `mvn dependency:list -DincludeScope=runtime -DoutputAbsoluteArtifactFilename=true | sed '/\.m2\/repository/!d' | sed 's/.*repository\//https:\/\/repo1\.maven\.org\/maven2\//' | sed -e 'H;${x;s/\n/ /g;s/^ //;p;};d'`
ARG EUREKA_PLUGIN_URLS='https://repo1.maven.org/maven2/com/hazelcast/hazelcast-eureka-one/2.0.1/hazelcast-eureka-one-2.0.1.jar https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar https://repo1.maven.org/maven2/org/codehaus/jettison/jettison/1.4.0/jettison-1.4.0.jar https://repo1.maven.org/maven2/io/github/x-stream/mxparser/1.2.1/mxparser-1.2.1.jar https://repo1.maven.org/maven2/com/google/inject/guice/4.1.0/guice-4.1.0.jar https://repo1.maven.org/maven2/joda-time/joda-time/2.3/joda-time-2.3.jar https://repo1.maven.org/maven2/com/google/guava/listenablefuture/9999.0-empty-to-avoid-conflict-with-guava/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.12.3/jackson-annotations-2.12.3.jar https://repo1.maven.org/maven2/aopalliance/aopalliance/1.0/aopalliance-1.0.jar https://repo1.maven.org/maven2/commons-configuration/commons-configuration/1.10/commons-configuration-1.10.jar https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar https://repo1.maven.org/maven2/com/netflix/servo/servo-core/0.12.21/servo-core-0.12.21.jar https://repo1.maven.org/maven2/com/netflix/netflix-commons/netflix-infix/0.3.0/netflix-infix-0.3.0.jar https://repo1.maven.org/maven2/commons-lang/commons-lang/2.6/commons-lang-2.6.jar https://repo1.maven.org/maven2/com/google/code/gson/gson/2.8.7/gson-2.8.7.jar https://repo1.maven.org/maven2/com/netflix/eureka/eureka-client/1.10.15/eureka-client-1.10.15.jar https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.6.4/slf4j-api-1.6.4.jar https://repo1.maven.org/maven2/antlr/antlr/2.7.7/antlr-2.7.7.jar https://repo1.maven.org/maven2/com/sun/jersey/jersey-core/1.19.1/jersey-core-1.19.1.jar https://repo1.maven.org/maven2/com/google/j2objc/j2objc-annotations/1.3/j2objc-annotations-1.3.jar https://repo1.maven.org/maven2/org/antlr/stringtemplate/3.2.1/stringtemplate-3.2.1.jar https://repo1.maven.org/maven2/org/apache/commons/commons-math/2.2/commons-math-2.2.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.12.2/jackson-databind-2.12.2.jar https://repo1.maven.org/maven2/javax/ws/rs/jsr311-api/1.1.1/jsr311-api-1.1.1.jar https://repo1.maven.org/maven2/com/thoughtworks/xstream/xstream/1.4.17/xstream-1.4.17.jar https://repo1.maven.org/maven2/com/netflix/archaius/archaius-core/0.7.7/archaius-core-0.7.7.jar https://repo1.maven.org/maven2/xmlpull/xmlpull/1.1.3.1/xmlpull-1.1.3.1.jar https://repo1.maven.org/maven2/com/github/andrewoma/dexx/dexx-collections/0.2/dexx-collections-0.2.jar https://repo1.maven.org/maven2/commons-codec/commons-codec/1.15/commons-codec-1.15.jar https://repo1.maven.org/maven2/javax/inject/javax.inject/1/javax.inject-1.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.12.3/jackson-core-2.12.3.jar https://repo1.maven.org/maven2/com/google/guava/failureaccess/1.0.1/failureaccess-1.0.1.jar https://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar https://repo1.maven.org/maven2/com/google/errorprone/error_prone_annotations/2.5.1/error_prone_annotations-2.5.1.jar https://repo1.maven.org/maven2/com/github/vlsi/compactmap/compactmap/2.0/compactmap-2.0.jar https://repo1.maven.org/maven2/com/google/guava/guava/30.1.1-jre/guava-30.1.1-jre.jar https://repo1.maven.org/maven2/org/checkerframework/checker-qual/3.8.0/checker-qual-3.8.0.jar https://repo1.maven.org/maven2/com/netflix/netflix-commons/netflix-eventbus/0.3.0/netflix-eventbus-0.3.0.jar https://repo1.maven.org/maven2/commons-jxpath/commons-jxpath/1.3/commons-jxpath-1.3.jar https://repo1.maven.org/maven2/com/sun/jersey/contribs/jersey-apache-client4/1.19.1/jersey-apache-client4-1.19.1.jar https://repo1.maven.org/maven2/javax/servlet/servlet-api/2.5/servlet-api-2.5.jar https://repo1.maven.org/maven2/org/apache/httpcomponents/httpcore/4.4.13/httpcore-4.4.13.jar https://repo1.maven.org/maven2/org/antlr/antlr-runtime/3.4/antlr-runtime-3.4.jar https://repo1.maven.org/maven2/com/sun/jersey/jersey-client/1.19.1/jersey-client-1.19.1.jar'

# Runtime constants / variables
ENV HZ_HOME="${HZ_HOME}" \
    CLASSPATH_DEFAULT="${HZ_HOME}/*:${HZ_HOME}/lib/*" \
    JAVA_OPTS_DEFAULT="-Djava.net.preferIPv4Stack=true -Dhz.network.rest-api.enabled=true -Dhz.network.rest-api.endpoint-groups.DATA.enabled=true -Dhazelcast.rest.enabled=true -Dhazelcast.logging.type=log4j2 -Dlog4j.configurationFile=${HZ_HOME}/log4j2.properties -XX:MaxRAMPercentage=80.0 -XX:MaxGCPauseMillis=5 --add-modules java.se --add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.management/sun.management=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    MANCENTER_URL="" \
    PROMETHEUS_PORT="" \
    PROMETHEUS_CONFIG="${HZ_HOME}/jmx_agent_config.yaml" \
    LOGGING_LEVEL="" \
    CLASSPATH=""

# Workaround for CVE-2021-44228
# https://www.docker.com/blog/apache-log4j-2-cve-2021-44228/
ENV JAVA_OPTS="-Dlog4j.formatMsgNoLookups=true"

# Expose port
EXPOSE 5701

COPY *.xml *.sh *.yaml *.properties ${HZ_HOME}/

# Install
RUN set -e; \
    apt-get --allow-releaseinfo-change update \
    && apt-get -y install \
    openjdk-11-jdk-headless \
    maven \
    bash \
    curl \
    procps \
    net-tools \
    telnet \
    inetutils-ping \
    libxml2-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install
RUN echo "Downloading Hazelcast and related JARs" \
    && mkdir "${HZ_HOME}/lib" \
    && cd "${HZ_HOME}/lib" \
    && HAZELCAST_ALL_URL=$(${HZ_HOME}/get-hz-all-url.sh) \
    && for JAR_URL in ${HAZELCAST_ALL_URL} ${CACHE_API_URL} ${PROMETHEUS_AGENT_URL} ${EUREKA_PLUGIN_URLS} ${LOG4J2_URLS}; do curl -sf -O -L ${JAR_URL} || exit $?; done \
    && echo "${HZ_VERSION_SHA} hazelcast-all-${HZ_VERSION}.jar" | sha256sum -c \
    && mv jmx_prometheus_javaagent-*.jar jmx_prometheus_javaagent.jar \
    && echo "Setting Pardot ID to 'docker'" \
    && echo 'hazelcastDownloadId=docker' > "hazelcast-download.properties" \
    && zip -u hazelcast-all-*.jar hazelcast-download.properties \
    && echo "Granting read permission to ${HZ_HOME}" \
    && chmod -R +r ${HZ_HOME} \
    && echo "Cleaning APK packages" \
    && rm -rf /var/cache/apk/* ${HZ_HOME}/get-hz-all-url.sh


RUN echo "Adding license to /usr/share/hazelcast directory" \
    && mkdir -p /usr/share/hazelcast/ \
    && curl https://raw.githubusercontent.com/hazelcast/hazelcast/master/LICENSE -o /usr/share/hazelcast/LICENSE


WORKDIR ${HZ_HOME}

# Start Hazelcast server
CMD ["/opt/hazelcast/start-hazelcast.sh"]
