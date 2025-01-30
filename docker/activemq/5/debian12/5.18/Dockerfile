

FROM marketplace.gcr.io/google/debian12 as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install ca-certificates curl

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
		&& chmod +x /download-licenses.sh \
		&& chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses \
		&& /download-ref-repos.sh /source_code.txt /usr/src

FROM marketplace.gcr.io/google/debian12

COPY --from=ospo /usr/src /usr/src

# This is release version of ActiveMQ to pull in.
ENV ACTIVEMQ_VERSION 5.18.5
ENV ACTIVEMQ apache-activemq-${ACTIVEMQ_VERSION}
ENV ACTIVEMQ_FILE ${ACTIVEMQ}-bin.tar.gz
ENV ACTIVEMQ_DOWNLOAD_URL http://archive.apache.org/dist/activemq/

ENV C2D_RELEASE 5.18.5

ENV ACTIVEMQ_TCP=61616 \
    ACTIVEMQ_AMQP=5672 \
    ACTIVEMQ_STOMP=61613 \
    ACTIVEMQ_MQTT=1883 \
    ACTIVEMQ_WS=61614 \
    ACTIVEMQ_UI=8161

ENV ACTIVEMQ_HOME /opt/activemq

ARG user=activemq
ARG group=activemq
ARG uid=1000
ARG gid=1000

RUN set -ex \
  && apt-get --allow-releaseinfo-change update \
  && apt-get -y install openjdk-17-jdk-headless ca-certificates wget procps \
  && rm -rf /var/lib/apt/lists/*

# ActiveMQ run with user `activemq`, uid = 1000.
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid.
RUN groupadd -g "${gid}" "${group}" \
    && useradd -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# Download and setup activemq version v5.18.5
RUN set -x && \
    mkdir -p "${ACTIVEMQ_HOME}" \
    && wget -q "${ACTIVEMQ_DOWNLOAD_URL}/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" -O "${ACTIVEMQ_FILE}" \
    && tar xzf "${ACTIVEMQ_FILE}" --strip-components=1  -C  "${ACTIVEMQ_HOME}" \
    && rm -rf "${ACTIVEMQ_FILE}" \
    && usermod -d "${ACTIVEMQ_HOME}" "${user}" \
    && chown -R "${user}":"${group}" "${ACTIVEMQ_HOME}"

RUN set -x && \
    # Converts version string to similar format: 5.15.x
    export ACTIVEMQ_LICENSE_VERSION="${ACTIVEMQ_VERSION%.*}.x" \
    # Copy License to container image
    && mkdir -p /usr/share/doc/activemq \
    && wget -q "https://raw.githubusercontent.com/apache/activemq/activemq-${ACTIVEMQ_LICENSE_VERSION}/LICENSE" -O /usr/share/doc/activemq/LICENSE

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x && \
    chown "${user}":"${group}" /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

USER "${user}"

WORKDIR ${ACTIVEMQ_HOME}
EXPOSE ${ACTIVEMQ_TCP} \
       ${ACTIVEMQ_AMQP} \
       ${ACTIVEMQ_STOMP} \
       ${ACTIVEMQ_MQTT} \
       ${ACTIVEMQ_WS} \
       ${ACTIVEMQ_UI}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash", "-c", "bin/activemq console"]
