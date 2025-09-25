FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

ENV EXPORTER_VERSION 0.28.0

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/statsd-exporter.tar.gz https://github.com/prometheus/statsd_exporter/releases/download/v${EXPORTER_VERSION}/statsd_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && tar xzf /opt/statsd-exporter.tar.gz --strip=1 -C /opt/

EXPOSE 9102/tcp
EXPOSE 9125/tcp
EXPOSE 9125/udp

HEALTHCHECK CMD wget --spider -S "http://localhost:9102/metrics" -T 60 2>&1 || exit 1

ENTRYPOINT ["/opt/statsd_exporter"]
