FROM marketplace.gcr.io/google/c2d-debian11

ARG STORM_VERSION="2.4.0"
ENV C2D_RELEASE "2.4.0"
ENV STORM_VERSION ${STORM_VERSION}

ENV STORM_CONF_DIR=/conf \
    STORM_DATA_DIR=/data \
    STORM_LOG_DIR=/logs \
    ZOO_CONF_DIR=/conf \
    ZOO_DIR=/apache-zookeeper

# create Storm data directories

RUN set -eux; \
    groupadd -r storm --gid=1000 ;\
    useradd -r -g storm --uid=1000 storm ;\
    mkdir -p "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"; \
    chown -R storm:storm "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"``

# Add Java 11
RUN apt-get update \
  && apt-get install -y openjdk-11-jdk


# Installing packags and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        openssl \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        procps \
        curl \
        wget; \
    rm -rf /var/lib/apt/lists/*; \
# Verify that gosu binary work
    gosu nobody true

# Set default version to Python 3
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

ARG GPG_KEY=51379DA8A7AE5B02674EF15C134716AF768D9B6E
ARG DISTRO_NAME=apache-storm-${STORM_VERSION}

ENV ZK_GPG_KEYS BBE7232D7991050B54C8EA0ADC08637CA615D22C

ARG ZK_SHORT_DISTRO_NAME="zookeeper-3.8.0"
ARG ZK_DISTRO_NAME="apache-zookeeper-3.8.0-bin"

RUN mkdir $ZOO_DIR

# Download Apache Storm and Apache Zookeeper
RUN set -eux; \
    ddist() { \
        local f="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
            https://www-us.apache.org/dist/ \
            https://www.apache.org/dist/ \
            https://archive.apache.org/dist/ \
        ; do \
            if wget -q -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
                success=1; \
                break; \
            fi; \
        done; \
        [ -n "$success" ]; \
    }; \
    ddist "$DISTRO_NAME.tar.gz" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    ddist "$DISTRO_NAME.tar.gz.asc" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    ddist "${ZK_DISTRO_NAME}.tar.gz" "zookeeper/${ZK_SHORT_DISTRO_NAME}/${ZK_DISTRO_NAME}.tar.gz"; \
    ddist "${ZK_DISTRO_NAME}.tar.gz.asc" "zookeeper/${ZK_SHORT_DISTRO_NAME}/${ZK_DISTRO_NAME}.tar.gz.asc"; \

#Verify Apache Storm PGP signature, untar and clean up.
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver hkps://keyserver.pgp.com --recv-key "$GPG_KEY" || \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$GPG_KEY" || \
    gpg --keyserver hkps://pgp.mit.edu --recv-keys "$GPG_KEY"; \
    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"; \
    chown -R storm:storm "$DISTRO_NAME" ; \

#Verify Apache Zookeeper PGP signature, untar and clean up.
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key ${ZK_GPG_KEYS} || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${ZK_GPG_KEYS} || \
    gpg --keyserver keyserver.pgp.com --recv-keys ${ZK_GPG_KEYS}; \
    gpg --batch --verify "${ZK_DISTRO_NAME}.tar.gz.asc" "${ZK_DISTRO_NAME}.tar.gz"; \
    tar -zxf "${ZK_DISTRO_NAME}.tar.gz" --strip-components=1 -C $ZOO_DIR; \
    mv "${ZOO_DIR}/conf/"* "${ZOO_CONF_DIR}"; \
    rm -rf "${GNUPGHOME}" "${ZK_DISTRO_NAME}.tar.gz" "${ZK_DISTRO_NAME}.tar.gz.asc"; \
    chown -R storm:storm "$ZOO_DIR"


WORKDIR $DISTRO_NAME

ENV PATH $PATH:/$DISTRO_NAME/bin

# ports
EXPOSE 8080 8000

# volume
VOLUME ["/logs"]

# copy configuration
COPY zoo.cfg /apache-zookeeper/conf/zoo.cfg

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/apache-zookeeper/bin/zkServer.sh", "start-foreground"]
