FROM marketplace.gcr.io/google/debian11

ENV EXPORTER_VERSION 0.22.5
ENV EXPORTER_SHA256 b04a25fe937a2e74dab097d589bd1f4da9e874d62b166c4e74d5d55b0f58eab6

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/statsd-exporter.tar.gz https://github.com/prometheus/statsd_exporter/releases/download/v${EXPORTER_VERSION}/statsd_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && echo "${EXPORTER_SHA256} /opt/statsd-exporter.tar.gz" | sha256sum -c \
    && tar xzf /opt/statsd-exporter.tar.gz --strip=1 -C /opt/

EXPOSE 9102/tcp
EXPOSE 9125/tcp
EXPOSE 9125/udp

HEALTHCHECK CMD wget --spider -S "http://localhost:9102/metrics" -T 60 2>&1 || exit 1

ENTRYPOINT ["/opt/statsd_exporter"]
