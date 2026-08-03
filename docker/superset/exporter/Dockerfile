FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV EXPORTER_VERSION 0.28.0

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade perl zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/statsd-exporter.tar.gz https://github.com/prometheus/statsd_exporter/releases/download/v${EXPORTER_VERSION}/statsd_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && tar xzf /opt/statsd-exporter.tar.gz --strip=1 -C /opt/

EXPOSE 9102/tcp
EXPOSE 9125/tcp
EXPOSE 9125/udp

HEALTHCHECK CMD wget --spider -S "http://localhost:9102/metrics" -T 60 2>&1 || exit 1

ENTRYPOINT ["/opt/statsd_exporter"]
