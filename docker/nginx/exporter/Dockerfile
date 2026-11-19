FROM marketplace.gcr.io/google/debian12@sha256:a623af62efaf2d260a05aae6869fd48ef8abedb957c6afd10028ac1a2993ba53

ENV EXPORTER_VERSION 1.5.3

COPY licenses/ /usr/share/doc/

RUN set -x \
        && apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y \
                openssl \
                wget \
                libtasn1-6 \
        && apt-get install -y --only-upgrade libpcre2-8-0 perl perl-base zlib1g \
        && rm -rf /var/lib/apt/lists/*

RUN set -x \
        && cd /usr/local/bin \
        && wget -q -O nginx-prometheus-exporter.tar.gz "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${EXPORTER_VERSION}/nginx-prometheus-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz" \
        && wget -q -O /usr/src/nginx-prometheus-exporter-v$EXPORTER_VERSION.tar.gz "https://github.com/nginxinc/nginx-prometheus-exporter/archive/refs/tags/v${EXPORTER_VERSION}.tar.gz" \
        && tar -xzf nginx-prometheus-exporter.tar.gz \
        && sed -i 's/\xff Go buildinf:/\xff Go_buildinf:/g' /usr/local/bin/nginx-prometheus-exporter \
        && rm -f nginx-prometheus-exporter.tar.gz

RUN chmod +rx /usr/local/bin/nginx-prometheus-exporter

EXPOSE 9113

ENTRYPOINT ["/usr/local/bin/nginx-prometheus-exporter"]
