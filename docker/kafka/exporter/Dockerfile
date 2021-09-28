FROM marketplace.gcr.io/google/debian10 as exporter-builder

ENV EXPORTER_VERSION 1.4.2
ENV EXPORTER_SHA512 42fcd2b303e82e3ea518cffe7c528c2c35f9ecace8427d68f556c8a91894056f9d8a84fb5bdac2c447b91870909f0dbcce5548a061149da4ffbf33e16545d488

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /kafka_exporter.tar.gz https://github.com/danielqsj/kafka_exporter/releases/download/v${EXPORTER_VERSION}/kafka_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && wget -O /opt/exporter.tar.gz https://github.com/danielqsj/kafka_exporter/archive/v${EXPORTER_VERSION}.tar.gz \
    && tar -xzf kafka_exporter.tar.gz --strip-components 1 \
    && echo "${EXPORTER_SHA512} /kafka_exporter.tar.gz" | sha512sum -c \
    && chmod +x /kafka_exporter

FROM marketplace.gcr.io/google/debian10

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9308

USER 1000

COPY --from=exporter-builder /kafka_exporter /kafka_exporter
COPY --from=exporter-builder /opt/exporter.tar.gz /opt/exporter.tar.gz

ENTRYPOINT ["/kafka_exporter"]
