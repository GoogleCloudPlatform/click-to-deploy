FROM marketplace.gcr.io/google/debian11

ARG ZK_VERSION=3.8.0

ENV ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_LOG_DIR=/logs \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60 \
    ZOO_STANDALONE_ENABLED=true \
    ZOO_ADMINSERVER_ENABLED=true

# Add a user with an explicit UID/GID and create necessary directories.
RUN set -eux; \
    groupadd -r zookeeper --gid=1000; \
    useradd -r -g zookeeper --uid=1000 zookeeper; \
    mkdir -p "${ZOO_DATA_LOG_DIR}" "${ZOO_DATA_DIR}" "${ZOO_CONF_DIR}" "${ZOO_LOG_DIR}"; \
    chown zookeeper:zookeeper "${ZOO_DATA_LOG_DIR}" "${ZOO_DATA_DIR}" "${ZOO_CONF_DIR}" "${ZOO_LOG_DIR}"

# Install required packages.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        default-jdk \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        netcat \
        openssl \
        wget; \
    rm -rf /var/lib/apt/lists/*; \
    # Verify that gosu binary works
    gosu nobody true

ENV GPG_KEYS BBE7232D7991050B54C8EA0ADC08637CA615D22C

ARG SHORT_DISTRO_NAME="zookeeper-${ZK_VERSION}"
ARG DISTRO_NAME="apache-zookeeper-${ZK_VERSION}-bin"

ENV C2D_RELEASE="${ZK_VERSION}"

# Download Apache Zookeeper, verify its PGP signature, untar and clean up.
RUN set -eux; \
    ddist() { \
        local f="${1}"; shift; \
        local distFile="${1}"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
            https://www-us.apache.org/dist/ \
            https://www.apache.org/dist/ \
            https://archive.apache.org/dist/ \
        ; do \
            if wget -q -O "${f}" "$distUrl$distFile" && [ -s "${f}" ]; then \
                success=1; \
                break; \
            fi; \
        done; \
        [ -n "${success}" ]; \
    }; \
    ddist "${DISTRO_NAME}.tar.gz" "zookeeper/${SHORT_DISTRO_NAME}/${DISTRO_NAME}.tar.gz"; \
    ddist "${DISTRO_NAME}.tar.gz.asc" "zookeeper/${SHORT_DISTRO_NAME}/${DISTRO_NAME}.tar.gz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key ${GPG_KEYS} || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${GPG_KEYS} || \
    gpg --keyserver keyserver.pgp.com --recv-keys ${GPG_KEYS}; \
    gpg --batch --verify "${DISTRO_NAME}.tar.gz.asc" "${DISTRO_NAME}.tar.gz"; \
    tar -zxf "${DISTRO_NAME}.tar.gz"; \
    mv "${DISTRO_NAME}/conf/"* "${ZOO_CONF_DIR}"; \
    rm -rf "${GNUPGHOME}" "${DISTRO_NAME}.tar.gz" "${DISTRO_NAME}.tar.gz.asc"; \
    chown -R zookeeper:zookeeper "/${DISTRO_NAME}"

WORKDIR "${DISTRO_NAME}"
VOLUME ["${ZOO_DATA_DIR}", "${ZOO_DATA_LOG_DIR}", "${ZOO_LOG_DIR}"]

EXPOSE 2181 2888 3888 8080

ENV PATH="${PATH}:/${DISTRO_NAME}/bin" \
    ZOOCFGDIR="${ZOO_CONF_DIR}"

COPY docker-entrypoint.sh /

RUN chmod 775 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["zkServer.sh", "start-foreground"]
