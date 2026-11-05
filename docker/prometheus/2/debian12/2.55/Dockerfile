
FROM docker.io/library/golang:1.26-bookworm AS builder

ENV PROMETHEUS_VERSION 2.55.1

RUN set -x && \
    mkdir -p /out && \
    git clone --depth 1 --branch "v${PROMETHEUS_VERSION}" https://github.com/prometheus/prometheus.git /src/prometheus && \
    cd /src/prometheus && \
    wget -qO- "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-web-ui-${PROMETHEUS_VERSION}.tar.gz" | tar xzf - -C web/ui && \
    ./scripts/compress_assets.sh && \
    case "${PROMETHEUS_VERSION}" in 2.*) go get golang.org/x/crypto@v0.52.0 google.golang.org/grpc@v1.79.3 && go mod tidy ;; esac && \
    CGO_ENABLED=0 go build -buildvcs=false -tags netgo,builtinassets,stringlabels \
      -ldflags="-s -w -X github.com/prometheus/common/version.Version=${PROMETHEUS_VERSION}" \
      -o /out/ ./cmd/prometheus ./cmd/promtool

FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

ENV PROMETHEUS_VERSION 2.55.1

ENV PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

ENV C2D_RELEASE ${PROMETHEUS_VERSION}

RUN set -x && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get install -qq -y wget openssl libminizip-dev zlib1g-dev libtasn1-6 && \
    apt-get install -y --only-upgrade libgnutls30 libpcre2-8-0 perl perl-base zlib1g && \
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

COPY --from=builder /out/prometheus /bin/prometheus
COPY --from=builder /out/promtool /bin/promtool

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
