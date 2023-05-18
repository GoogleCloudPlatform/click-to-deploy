FROM marketplace.gcr.io/google/c2d-debian11 as build

SHELL ["/bin/bash", "-c" ]

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl\
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#install node
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && source ~/.bashrc \
    && nvm install 16

#install golang
ARG GOLANG_VERSION=1.18.7
ADD https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz /tmp/go.tar.gz
RUN (tar -xf /tmp/go.tar.gz -C /usr/local/ && rm /tmp/go.tar.gz) || true
ENV PATH="/usr/local/go/bin:${PATH}"

#copy projects
RUN mkdir /sources
ARG MANAGER_DIST=https://github.com/longhorn/longhorn-manager/archive/refs/tags/v1.4.2.tar.gz
ADD $MANAGER_DIST /tmp/manager.tar.gz
ARG ENGINE_DIST=https://github.com/longhorn/longhorn-engine/archive/refs/tags/v1.4.2.tar.gz
ADD $ENGINE_DIST /tmp/engine.tar.gz
ARG UI_DIST=https://github.com/longhorn/longhorn-ui/archive/refs/tags/v1.4.2.tar.gz
ADD $UI_DIST /tmp/ui.tar.gz
ARG INSTANCE_DIST=https://github.com/longhorn/longhorn-instance-manager/archive/refs/tags/v1_20221003.tar.gz
ADD $INSTANCE_DIST /tmp/instance.tar.gz
RUN for f in /tmp/*.tar.gz; do tar -xf "$f" -C /sources/; done
RUN source ~/.bashrc \
    && for package in /sources/*; do cd "$package" && (go mod vendor || npm i --omit=dev); done
#copy licenses
RUN mkdir /usr/share/external-licenses \
    && find /sources/*/vendor/ -name 'LICENS*' -exec cp --parents "{}" /usr/share/external-licenses/ \; \
    && source ~/.bashrc \
    && npm i -g nlf \
    && cd /sources/longhorn-ui* \
    && find $(nlf -c -d -r 1|grep -v directory|awk -F, '{print $3}') -maxdepth 1 -iname 'licens*' -exec cp --parents "{}" /usr/share/external-licenses/ \;

FROM marketplace.gcr.io/google/c2d-debian11

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl nginx \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#copy licenses
COPY --from=build /usr/share/external-licenses/ /usr/share/external-licenses/
#copy binaries
COPY --from=docker.io/longhornio/longhorn-manager:v1.4.2 \
     /usr/local/sbin/launch-manager /usr/local/sbin/
COPY --from=docker.io/longhornio/longhorn-engine:v1.4.2 \
     /usr/local/bin/longhorn /usr/local/bin/engine-manager /usr/local/bin/
COPY --from=docker.io/longhornio/longhorn-ui:v1.4.2 \
     /web/dist /web/dist
COPY --from=docker.io/longhornio/longhorn-ui:v1.4.2 \
     /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY --from=docker.io/longhornio/longhorn-instance-manager:v1.4.2 \
     /usr/local/bin/longhorn-instance-manager /usr/local/bin

ENV C2D_RELEASE 1.4.2
