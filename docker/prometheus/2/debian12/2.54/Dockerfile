FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861
ENV PROMETHEUS_VERSION 2.54.1

ENV PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

ENV C2D_RELEASE ${PROMETHEUS_VERSION}

RUN set -x && \
    apt-get update && apt-get install -qq -y wget openssl libminizip-dev zlib1g-dev libtasn1-6 && \
    mkdir -p /etc/prometheus && \
    mkdir -p /usr/share/prometheus && \
    mkdir prometheus-files && cd prometheus-files && \
    wget -O prometheus.tar.gz "$PROMETHEUS_URL" && \
    tar xfvz prometheus.tar.gz --strip-components=1 && \
    mv prometheus          /bin/ && \
    mv promtool            /bin/ && \
    mv prometheus.yml      /etc/prometheus/ && \
    # v3 compatibility checks: Only move directories if they exist in the archive
    if [ -d console_libraries ]; then mv console_libraries /usr/share/prometheus/; fi && \
    if [ -d consoles ]; then mv consoles /usr/share/prometheus/; fi && \
    cd - && \
    rm -r prometheus-files && \
    # Only symlink directories if they were moved
    if [ -d /usr/share/prometheus/console_libraries ]; then ln -s /usr/share/prometheus/console_libraries /etc/prometheus; fi && \
    if [ -d /usr/share/prometheus/consoles ]; then ln -s /usr/share/prometheus/consoles /etc/prometheus; fi && \
    mkdir -p /prometheus && \
    chown -R nobody:nogroup /etc/prometheus /prometheus && \
    # Clean lists to reduce final image size
    rm -rf /var/lib/apt/lists/*

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
