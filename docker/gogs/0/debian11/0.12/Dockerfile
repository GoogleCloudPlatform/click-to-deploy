FROM marketplace.gcr.io/google/debian11:latest AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git ca-certificates rsync \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION 1.14
ARG GOSU_DIST=https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64
ADD $GOSU_DIT /usr/sbin/gosu
RUN chmod a+x /usr/sbin/gosu

WORKDIR /opt/gogs

ENV GOGS_VERSION 0.12.10
ARG GOGS_DIST=https://github.com/gogs/gogs/releases/download/v$GOGS_VERSION/gogs_$GOGS_VERSION_linux_amd64.tar.gz
ADD $GOGS_DIST ./
RUN (tar -xvf ./gogs-*.tar.gz && \
    rm ./gogs-*.tar.gz) || true
RUN mv ./gogs-* ./ && mkdir /data
RUN addgroup -S git \
    && adduser -G git -H -D -g 'Gogs Git User' git -h /data/git -s /bin/bash \
    && usermod -p '*' git \
    && passwd -u git

ENV GOGS_CUSTOM /data/gogs

ENV C2D_RELEASE 0.12.10

USER git

VOLUME ["/data", "/backup"]
EXPOSE 22 3000

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
