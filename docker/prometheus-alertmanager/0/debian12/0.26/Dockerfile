FROM marketplace.gcr.io/google/debian12
ENV ALERTMANAGER_VERSION 0.26.0
ENV C2D_RELEASE=${ALERTMANAGER_VERSION}

ENV ALERTMANAGER_URL="https://github.com/prometheus/alertmanager/releases/download/v$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz"

RUN set -x && \
    apt-get update && apt-get install -qq -y wget && \
    mkdir -p /etc/alertmanager && \
    mkdir alertmanager-files && cd alertmanager-files && \
    wget -O alertmanager.tar.gz "$ALERTMANAGER_URL" && \
    tar xfvz alertmanager.tar.gz --strip-components=1 && \
    mv amtool          /bin/ && \
    mv alertmanager    /bin/ && \
    mkdir -p /usr/share/doc/alertmanager && \
    mv LICENSE /usr/share/doc/alertmanager/ && \
    mv alertmanager.yml /etc/alertmanager/alertmanager.yml && \
    cd - && \
    rm -r alertmanager-files

EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /etc/alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--storage.path=/alertmanager" ]
