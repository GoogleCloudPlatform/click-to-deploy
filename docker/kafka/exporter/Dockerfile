FROM marketplace.gcr.io/google/debian11 as exporter-builder

ENV EXPORTER_VERSION 1.4.2
ENV EXPORTER_SHA512 42fcd2b303e82e3ea518cffe7c528c2c35f9ecace8427d68f556c8a91894056f9d8a84fb5bdac2c447b91870909f0dbcce5548a061149da4ffbf33e16545d488

ENV EXPORTER_USER="exporter" \
    EXPORTER_UID="9308" \
    EXPORTER_GROUP="exporter" \
    EXPORTER_GID="9308" \
    EXPORTER_HOME=/opt/exporter

ENV PATH="${PATH}:${EXPORTER_HOME}"

RUN set -ex; \
  groupadd -r --gid "${EXPORTER_GID}" "${EXPORTER_GROUP}"; \
  useradd -r --uid "${EXPORTER_UID}" --gid "${EXPORTER_GID}" -s /sbin/nologin "${EXPORTER_USER}"

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends curl\
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${EXPORTER_HOME} \
    && cd ${EXPORTER_HOME} \
    && curl -sSL -o kafka_exporter.tar.gz https://github.com/danielqsj/kafka_exporter/releases/download/v${EXPORTER_VERSION}/kafka_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && curl -sSL -o exporter.tar.gz https://github.com/danielqsj/kafka_exporter/archive/v${EXPORTER_VERSION}.tar.gz \
    && tar -xzf kafka_exporter.tar.gz --strip-components 1 \
    && echo "${EXPORTER_SHA512} kafka_exporter.tar.gz" | sha512sum -c \
    && chown -R ${EXPORTER_USER}:${EXPORTER_GROUP} ${EXPORTER_HOME} \
    && chmod +x ${EXPORTER_HOME}/kafka_exporter

EXPOSE 9308
WORKDIR ${EXPORTER_HOME}
USER ${EXPORTER_USER}

ENTRYPOINT ["kafka_exporter"]
