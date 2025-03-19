FROM marketplace.gcr.io/google/debian12

ENV NGINX_VERSION 1.26.2*
ENV C2D_RELEASE 1.26.2

ENV ENABLE_STUB_STATUS false

RUN set -x \
        && apt-get update \
        && apt-get install -y \
                dirmngr \
                gnupg \
                wget \
                libtasn1-6 \
        && rm -rf /var/lib/apt/lists/*

RUN set -x \
        && echo "deb http://nginx.org/packages/debian/ bookworm nginx" >> /etc/apt/sources.list \
        && wget http://nginx.org/packages/keys/nginx_signing.key \
        && apt-key add nginx_signing.key \
        && apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                                                ca-certificates \
                                                nginx=${NGINX_VERSION} \
                                                nginx-module-xslt=${NGINX_VERSION} \
                                                nginx-module-geoip=${NGINX_VERSION} \
                                                nginx-module-image-filter=${NGINX_VERSION} \
                                                nginx-module-perl=${NGINX_VERSION} \
                                                nginx-module-njs=${NGINX_VERSION} \
                                                gettext-base \
        && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY stub.conf /etc/nginx/stub.conf.template

RUN chmod +rx /usr/local/bin/docker-entrypoint.sh

EXPOSE 80 443 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
