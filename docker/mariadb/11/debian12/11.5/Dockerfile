ARG BASE_REGISTRY="marketplace.gcr.io/google"
ARG BASE_IMAGE="debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861"
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS bootstrap

RUN apt-get update && \
    apt-get install --no-install-recommends -y --allow-change-held-packages \
        gnupg curl ca-certificates apt-utils && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo 'deb http://packages.cloud.google.com/apt apt-transport-artifact-registry-stable main' | tee -a /etc/apt/sources.list.d/artifact-registry.list

RUN apt-get update && apt-get install apt-transport-artifact-registry

# New clean base so we aren't fetching "gnupg curl apt-utils" if not needed
FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861 as base

# ca-certificates is required for https
RUN apt-get update && \
    apt-get install --no-install-recommends -y --allow-change-held-packages \
        ca-certificates

# Copy only the AR transport binary from the bootstrap stage
COPY --from=bootstrap "/usr/lib/apt/methods/ar+https" "/usr/lib/apt/methods/ar+https"
# Copy the apache notice type license for OSPO
COPY --from=bootstrap "/usr/share/doc/apt-transport-artifact-registry" "/usr/share/doc/apt-transport-artifact-registry"

# Remove all other apt sources
RUN rm -f /etc/apt/sources.list.d/* /etc/apt/sources.list

# This ARG allows passing credentials path during the build
ARG GOOGLE_APPLICATION_CREDENTIALS

# Use a secret mount to securely add the Airlock apt repository and update
RUN --mount=type=secret,id=credentials \
    echo 'deb ar+https://us-apt.pkg.dev/remote/artifact-foundry-prod/debian-3p-remote-bookworm bookworm main' | \
    tee -a  /etc/apt/sources.list.d/artifact-registry.list && \
    apt-get update

FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS gosu-build
RUN --mount=type=secret,id=credentials \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gosu \
        arch-test \
        file \
        patch \
        git \
        golang; \
    rm -rf /var/lib/apt/lists/*

# Final image

FROM ${BASE_REGISTRY}/${BASE_IMAGE}
ENV C2D_RELEASE 11.5.2

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN --mount=type=secret,id=credentials \
    set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
        mariadb-client-core \
        mariadb-server-core \
        mariadb-backup \
        socat \
        libjemalloc2 \
        pwgen \
        tzdata \
        xz-utils \
        zstd \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*
 
# Add gosu from gosu-build
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends gosu && \
    rm -rf /var/lib/apt/lists/*

RUN gosu --version && gosu nobody true
 
# MariaDB runtime setup

RUN mkdir /docker-entrypoint-initdb.d
ENV LANG C.UTF-8
RUN set -ex; \

    { \

        echo "mariadb-server" mysql-server/root_password password 'unused'; \

        echo "mariadb-server" mysql-server/root_password_again password 'unused'; \

    } | debconf-set-selections; \

    find /etc/mysql/ -name '*.cnf' -print0 \

        | xargs -0 grep -lZE '^(bind-address|log|user\s)' \

        | xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/'; \

    printf "[mariadb]\nhost-cache-size=0\nskip-name-resolve\n" \
> /etc/mysql/mariadb.conf.d/05-skipcache.cnf; \

    if [ -L /etc/mysql/my.cnf ]; then \

        sed -i -e '/includedir/ {N;s/\(.*\)\n\(.*\)/\n\2\n\1/}' /etc/mysql/mariadb.cnf; \

    fi
 
VOLUME /var/lib/mysql
 
COPY healthcheck.sh /usr/local/bin/healthcheck.sh

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
 
EXPOSE 3306

CMD ["mariadbd"]