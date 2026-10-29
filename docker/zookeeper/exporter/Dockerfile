FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c as exporter-builder

ENV EXPORTER_VERSION 1.1.0
ENV EXPORTER_SHA256 c7446aa33d3505fc8b4a92327c89a543f217ebb246c76880ea796f2893d40418

RUN set -eu \
    ## Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /zookeeper_exporter https://github.com/carlpett/zookeeper_exporter/releases/download/v${EXPORTER_VERSION}/zookeeper_exporter \
    && wget -O /opt/exporter.tar.gz https://github.com/carlpett/zookeeper_exporter/archive/v${EXPORTER_VERSION}.tar.gz \
    && echo "${EXPORTER_SHA256} /zookeeper_exporter" | sha256sum -c \
    && chmod +x /zookeeper_exporter

FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

RUN set -eu \
    # Installing utilities
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends curl \
    && rm -f /usr/share/perl/*/Digest/SHA.xs \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9141

USER 1000

COPY --from=exporter-builder /zookeeper_exporter /zookeeper_exporter
COPY --from=exporter-builder /opt/exporter.tar.gz /opt/exporter.tar.gz

ENTRYPOINT ["/zookeeper_exporter"]
