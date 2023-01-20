FROM marketplace.gcr.io/google/debian11

ENV EXPORTER_VERSION 0.7.0
ENV EXPORTER_SHA256 cda8d6c60c240c73c28ed0d4e81cb7b52808dcf0358aec41fddc93a30d1e68b7

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget libtasn1-6 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/falco-exporter.tar.gz https://github.com/falcosecurity/falco-exporter/releases/download/v${EXPORTER_VERSION}/falco-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz \
    && echo "${EXPORTER_SHA256} /opt/falco-exporter.tar.gz" | sha256sum -c \
    && tar xzf /opt/falco-exporter.tar.gz -C /opt/

EXPOSE 9376/tcp
EXPOSE 19376/tcp

ENTRYPOINT ["/opt/falco-exporter"]
