# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

FROM marketplace.gcr.io/google/c2d-debian11

ENV NEO4J_VERSION 5.8.0
ENV NEO4J_HOME  /var/lib/neo4j
ENV NEO4J_EDITION community
ENV NEO4J_TARBALL neo4j.tar.gz

ENV TINI_VERSION v0.19.0

# Required for neo4jlabs-plugins.json
ENV DOCKER_NEO4J_VERSION 5.8.0
ENV DOCKER_NEO4J_TARBALL docker-neo4j.tar.gz

ENV C2D_RELEASE 5.8.0

# Workaround for CVE-2021-44228
# https://www.docker.com/blog/apache-log4j-2-cve-2021-44228/
ENV JAVA_OPTS="-Dlog4j.formatMsgNoLookups=true"

RUN addgroup --system neo4j && adduser --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

RUN apt update \
    && apt install -y curl wget gosu jq \
    && curl -L --fail --silent --show-error "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" > /sbin/tini \
    && chmod +x /sbin/tini \
    && curl -o ${NEO4J_TARBALL} --fail --silent --show-error --location --remote-name https://dist.neo4j.org/neo4j-community-${NEO4J_VERSION}-unix.tar.gz \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
    && curl -o ${DOCKER_NEO4J_TARBALL} --fail --silent --show-error --location --remote-name https://github.com/neo4j/docker-neo4j/archive/refs/tags/neo4j-${DOCKER_NEO4J_VERSION}.tar.gz \
    && tar --extract --file ${DOCKER_NEO4J_TARBALL} --directory /tmp \
    && mv /tmp/docker-neo4j*/docker-image-src/common/neo4jlabs-plugins.json /neo4jlabs-plugins.json \
    && rm ${DOCKER_NEO4J_TARBALL} \
    && rm ${NEO4J_TARBALL} \
    && mv "${NEO4J_HOME}"/data /data \
    && mv "${NEO4J_HOME}"/logs /logs \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /logs \
    && chmod -R 777 /logs \
    && chown -R neo4j:neo4j "${NEO4J_HOME}" \
    && chmod -R 777 "${NEO4J_HOME}" \
    && ln -s /data "${NEO4J_HOME}"/data \
    && ln -s /logs "${NEO4J_HOME}"/logs \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y purge --auto-remove curl

# Add debian backport source repository
RUN set -x \
    && echo 'deb http://ftp.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/bullseye-backports.list \
    && apt update \
    && apt install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Add up-to-date libs for security purposes
RUN set -x \
    apt update \
    && apt install -y \
      dpkg \
      gpgv \
      libc6 \
      libc-bin \
      libgnutls30 \
      libtirpc3 \
      libtirpc-common \
      libssl1.1 \
      openssl \
      zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV PATH "${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]
