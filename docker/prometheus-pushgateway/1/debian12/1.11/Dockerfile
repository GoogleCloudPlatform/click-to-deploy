FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861
ENV PUSHGATEWAY_VERSION 1.11.1

ENV C2D_RELEASE=${PUSHGATEWAY_VERSION}

ENV PUSHGATEWAY_URL="https://github.com/prometheus/pushgateway/releases/download/v$PUSHGATEWAY_VERSION/pushgateway-$PUSHGATEWAY_VERSION.linux-amd64.tar.gz"

RUN set -x && \
    apt-get update && apt-get install -qq -y wget && \
    mkdir pushgateway-files && cd pushgateway-files && \
    wget -O pushgateway.tar.gz "$PUSHGATEWAY_URL" && \
    tar xfvz pushgateway.tar.gz --strip-components=1 && \
    mv pushgateway /bin/ && \
    mkdir -p /usr/share/doc/pushgateway && \
    mv LICENSE /usr/share/doc/pushgateway && \
    cd - && rm -r pushgateway-files && \
    mkdir -p /pushgateway

EXPOSE     9091
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/pushgateway" ]
