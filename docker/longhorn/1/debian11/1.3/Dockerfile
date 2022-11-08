FROM marketplace.gcr.io/google/debian11

SHELL ["/bin/bash", "-c" ]

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl nginx \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#install node
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && source ~/.bashrc \
    && nvm install 16

#copy binaries
COPY --from=docker.io/longhornio/longhorn-manager:v1.3.2 \
     /usr/local/sbin/launch-manager /usr/local/sbin/
COPY --from=docker.io/longhornio/longhorn-engine:v1.3.2 \
     /usr/local/bin/longhorn /usr/local/bin/engine-manager /usr/local/bin/
COPY --from=docker.io/longhornio/longhorn-ui:v1.3.2 \
     /web/dist /web/dist
COPY --from=docker.io/longhornio/longhorn-ui:v1.3.2 \
     /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY --from=docker.io/longhornio/longhorn-instance-manager:v1.3.x-head \
     /usr/local/bin/longhorn-instance-manager /usr/local/bin

ENV C2D_RELEASE 1.3.2
