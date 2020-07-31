FROM gcr.io/google-appengine/debian9:latest as exporter-builder

ENV EXPORTER_VERSION 1.0.2
ENV EXPORTER_SHA256 e814444e9bc0c7b8a8fd01edb131ce2ae74704257fc62a4430156bb2656450cb

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /zookeeper_exporter https://github.com/carlpett/zookeeper_exporter/releases/download/v${EXPORTER_VERSION}/zookeeper_exporter \
    && wget -O /opt/exporter.tar.gz https://github.com/carlpett/zookeeper_exporter/archive/v${EXPORTER_VERSION}.tar.gz \
    && echo "${EXPORTER_SHA256} /zookeeper_exporter" | sha256sum -c \
    && chmod +x /zookeeper_exporter

FROM gcr.io/google-appengine/debian9:latest

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9141

USER 1000

COPY --from=exporter-builder /zookeeper_exporter /zookeeper_exporter
COPY --from=exporter-builder /opt/exporter.tar.gz /opt/exporter.tar.gz

ENTRYPOINT ["/zookeeper_exporter"]
