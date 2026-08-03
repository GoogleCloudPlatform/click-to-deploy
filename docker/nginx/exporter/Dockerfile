FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV EXPORTER_VERSION 1.5.1

COPY licenses/ /usr/share/doc/

RUN set -x \
        && apt-get update \
        && apt-get install -y \
                openssl \
                wget \
                libtasn1-6 \
        && apt-get install -y --only-upgrade perl zlib1g \
        && rm -rf /var/lib/apt/lists/*

RUN set -x \
        && cd /usr/local/bin \
        && wget -q -O nginx-prometheus-exporter.tar.gz "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${EXPORTER_VERSION}/nginx-prometheus-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz" \
        && wget -q -O /usr/src/nginx-prometheus-exporter-v$EXPORTER_VERSION.tar.gz "https://github.com/nginxinc/nginx-prometheus-exporter/archive/refs/tags/v${EXPORTER_VERSION}.tar.gz" \
        && tar -xzf nginx-prometheus-exporter.tar.gz \
        && rm -f nginx-prometheus-exporter.tar.gz

RUN chmod +rx /usr/local/bin/nginx-prometheus-exporter

EXPOSE 9113

ENTRYPOINT ["/usr/local/bin/nginx-prometheus-exporter"]
