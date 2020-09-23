FROM gcr.io/google-appengine/openjdk

# This is release version of ActiveMQ to pull in.
ENV ACTIVEMQ_VERSION 5.16.0
ENV ACTIVEMQ_SHA512 999928176e57b0805e8a53834e7f4eb648baf271a0c60de31ebd95fa63f2b089aa41c2ef7353790835e2e8cc39c4b778f535b38e6dc0c67a79c3c1da335c4a0a
ENV ACTIVEMQ apache-activemq-${ACTIVEMQ_VERSION}
ENV ACTIVEMQ_FILE ${ACTIVEMQ}-bin.tar.gz
ENV ACTIVEMQ_DOWNLOAD_URL http://archive.apache.org/dist/activemq/

ENV C2D_RELEASE 5.16.0

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

# ActiveMQ run with user `activemq`, uid = 1000.
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid.
RUN groupadd -g "${gid}" "${group}" \
    && useradd -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# Download and setup activemq version v5.16.0
RUN set -x && \
    mkdir -p "${ACTIVEMQ_HOME}" \
    && wget -q "${ACTIVEMQ_DOWNLOAD_URL}/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" -O "${ACTIVEMQ_FILE}" \
    && echo "${ACTIVEMQ_SHA512}" "${ACTIVEMQ_FILE}" | sha512sum -c \
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
