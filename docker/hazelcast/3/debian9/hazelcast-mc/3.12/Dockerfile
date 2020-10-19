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

# Add debian backport source repository
RUN set -x \
    && echo 'deb http://ftp.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list \
    && apt update \
    && apt install --no-install-recommends -y \
    ntp \
    wget \
    unzip \
    curl \
    openjdk-11-jdk \
    inetutils-ping \
    && rm -rf /var/lib/apt/lists/*

ENV MC_VERSION 3.12.7
ENV MC_INSTALL_SHA256=a12528ec4907ca03042944c84397d1bd846486c0b8099b611b30bb50c47b792a
ENV MC_HOME /opt/hazelcast/mancenter
ENV MC_DATA /data

ENV MC_HTTP_PORT 8080
ENV MC_HTTPS_PORT 8443
ENV MC_HEALTH_CHECK_PORT 8081
ENV MC_CONTEXT hazelcast-mancenter

ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_WAR="hazelcast-mancenter-${MC_VERSION}.war"

ENV MC_RUNTIME "${MC_HOME}/${MC_INSTALL_WAR}"

# chmod allows running container as non-root with `docker run --user` option
RUN set -e; \
     mkdir -p "${MC_HOME}" "${MC_DATA}" \
     && chmod a+rwx "${MC_HOME}" "${MC_DATA}"

WORKDIR "${MC_HOME}"

# Prepare Management Center
RUN set -e; \
     wget -O "${MC_HOME}/${MC_INSTALL_ZIP}" \
          "http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP}" \
     && echo "${MC_INSTALL_SHA256}" "${MC_INSTALL_ZIP}" | sha256sum -c \
     && unzip "${MC_INSTALL_ZIP}" \
     -x "${MC_INSTALL_NAME}/docs/*" \
     && rm -rf "${MC_INSTALL_ZIP}" \
     && mv "${MC_INSTALL_NAME}"/* . \
     && rm -rf "${MC_INSTALL_NAME}"

RUN echo "Adding license to /usr/share/hazelcast directory" \
    && mkdir -p /usr/share/hazelcast-management-center/ \
    && curl https://raw.githubusercontent.com/hazelcast/hazelcast/master/LICENSE \
        -o /usr/share/hazelcast-management-center/LICENSE

# Runtime environment variables
ENV JAVA_OPTS_DEFAULT "-Dhazelcast.mancenter.home=${MC_DATA} -Djava.net.preferIPv4Stack=true"

ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""

ENV JAVA_OPTS ""
ENV MC_INIT_SCRIPT ""
ENV MC_INIT_CMD ""

ENV MC_CLASSPATH ""

COPY mc-start.sh /mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT}
EXPOSE ${MC_HTTPS_PORT}
EXPOSE ${MC_HEALTH_CHECK_PORT}

# Start Management Center
CMD ["bash", "/mc-start.sh"]
