FROM marketplace.gcr.io/google/debian12

ENV EXPORTER_VERSION 1.9.0

ENV EXPORTER_USER="exporter" \
    EXPORTER_UID="9308" \
    EXPORTER_GROUP="exporter" \
    EXPORTER_GID="9308" \
    EXPORTER_HOME=/opt/exporter

ENV PATH="${PATH}:${EXPORTER_HOME}"

RUN set -ex; \
  apt update \
  && apt -y install ca-certificates curl \
  && groupadd -r --gid "${EXPORTER_GID}" "${EXPORTER_GROUP}" \
  && useradd -r --uid "${EXPORTER_UID}" --gid "${EXPORTER_GID}" -s /sbin/nologin "${EXPORTER_USER}"

RUN set -eu \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${EXPORTER_HOME} \
    && cd ${EXPORTER_HOME} \
    && curl -sSL -o kafka_exporter.tar.gz https://github.com/danielqsj/kafka_exporter/releases/download/v${EXPORTER_VERSION}/kafka_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && curl -sSL -o exporter.tar.gz https://github.com/danielqsj/kafka_exporter/archive/v${EXPORTER_VERSION}.tar.gz \
    && tar -xzf kafka_exporter.tar.gz --strip-components 1 \
    && chown -R ${EXPORTER_USER}:${EXPORTER_GROUP} ${EXPORTER_HOME} \
    && chmod +x ${EXPORTER_HOME}/kafka_exporter

EXPOSE 9308
WORKDIR ${EXPORTER_HOME}
USER ${EXPORTER_USER}

ENTRYPOINT ["kafka_exporter"]
