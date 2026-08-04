FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0
ENV PROMETHEUS_VERSION 2.54.1

ENV PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

ENV C2D_RELEASE ${PROMETHEUS_VERSION}

RUN set -x && \
    apt-get update && apt-get install -qq -y wget openssl libminizip-dev zlib1g-dev libtasn1-6 && \
    apt-get install -y --only-upgrade perl zlib1g && \
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
