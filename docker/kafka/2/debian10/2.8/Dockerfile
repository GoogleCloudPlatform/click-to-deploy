FROM marketplace.gcr.io/google/debian10

ARG KAFKA_VERSION=2.8.1
ARG SCALA_VERSION=<no value>
ARG KAFKA_SHA512=91fcd1061247ad0ddb63fa2b5c0251ee0e58e60cc9e1a3ebe2e84e9a31872448a36622dd15868de2c6d3f7e26020a8c61477bc764e2fb6776a25e4344eb8892d

ENV C2D_RELEASE 2.8.1

RUN set -ex \
  && apt-get update \
  && apt-get -y install default-jdk curl ca-certificates jq net-tools \
  && rm -rf /var/lib/apt/lists/*

ENV KAFKA_USER="kafka" \
    KAFKA_UID="9092" \
    KAFKA_GROUP="kafka" \
    KAFKA_GID="9092" \
    KAFKA_HOME=/opt/kafka \
    KAFKA_DOCKER_SCRIPTS=/opt/docker-kafka/scripts \
    KAFKA_LOG_DIRS=/kafka \
    KAFKA_DIST_URL="https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"

ENV PATH="${PATH}:${KAFKA_HOME}/bin"

# Kafka run with user `kafka`, uid = 9092.
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid.
RUN set -ex; \
  groupadd -r --gid "${KAFKA_GID}" "${KAFKA_GROUP}"; \
  useradd -r --uid "${KAFKA_UID}" --gid "${KAFKA_GID}" -s /sbin/nologin "${KAFKA_USER}"

COPY --chown=$KAFKA_USER:$KAFKA_GROUP scripts ${KAFKA_DOCKER_SCRIPTS}

# Download and setup kafka version v2.8.1
RUN chmod a+x ${KAFKA_DOCKER_SCRIPTS}/*.sh \
  && ln -s ${KAFKA_DOCKER_SCRIPTS}/*.sh /usr/bin \
  && curl -sSL ${KAFKA_DIST_URL} -o "/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
  && echo "${KAFKA_SHA512} /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | sha512sum -c - \
  && tar -xzf /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
  && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
  && chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_HOME} \
  && mkdir -p ${KAFKA_LOG_DIRS} \
  && chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_LOG_DIRS} \
  && rm /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

COPY --chown=${KAFKA_USER}:${KAFKA_GROUP} scripts/overrides /opt/overrides

RUN set -x && \
    export KAFKA_LICENSE_VERSION="${KAFKA_VERSION}" \
    # Copy License to container image
    && mkdir -p /usr/share/doc/kafka \
    && curl -sSL https://raw.githubusercontent.com/apache/kafka/${KAFKA_VERSION}/LICENSE \
    -o /usr/share/doc/kafka/LICENSE

VOLUME ${KAFKA_LOG_DIRS}
EXPOSE 9092
WORKDIR ${KAFKA_HOME}
USER ${KAFKA_USER}

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-kafka.sh"]
