FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0 as ospo

# Download Licenses
COPY components.csv /components.csv

RUN apt update && apt -y install curl ca-certificates \
    && curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& chmod +x /download-licenses.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses

FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

COPY --from=ospo /usr/src /usr/src

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

RUN set -ex; \
        if ! command -v gpg > /dev/null; then \
                apt-get update; \
                apt-get install -y --no-install-recommends \
                  apt-transport-https \
                  ca-certificates \
                  gnupg \
                  dirmngr \
                  openssl \
                ; \
                rm -rf /var/lib/apt/lists/*; \
        fi

# grab gosu for easy step-down from root and build from source to avoid Go vulnerabilities
ENV GOSU_VERSION 1.19
RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    git \
  ; \
  \
  # Install a secure Go version
  wget -qO- https://go.dev/dl/go1.25.9.linux-amd64.tar.gz | tar -C /usr/local -xzf -; \
  export PATH=$PATH:/usr/local/go/bin; \
  \
  # Compile gosu
  git clone --depth 1 -b "$GOSU_VERSION" https://github.com/tianon/gosu.git /usr/local/src/gosu; \
  cd /usr/local/src/gosu; \
  go build -ldflags '-w -s' -o /usr/local/bin/gosu; \
  \
  # Test gosu runs and clean up build dependencies
  /usr/local/bin/gosu nobody true; \
  rm -rf /usr/local/go /usr/local/src/gosu; \
  apt-get purge -y --auto-remove git wget; \
  rm -rf /var/lib/apt/lists/*

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN mkdir /docker-entrypoint-initdb.d

RUN set -ex; \
  key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
  export GNUPGHOME="$(mktemp -d)"; \
  found=''; \
  for server in \
    pool.sks-keyservers.net \
    ha.pool.sks-keyservers.net \
    pgp.mit.edu \
    na.pool.sks-keyservers.net \
    eu.pool.sks-keyservers.net \
    oc.pool.sks-keyservers.net \
    ha.pool.sks-keyservers.net \
    hkp://p80.pool.sks-keyservers.net:80 \
    hkp://keyserver.ubuntu.com:80 \
  ; do \
    gpg --no-tty --keyserver ${server} --recv-keys "$key" \
      && found="yes" && break; \
  done; \
  test -n "$found"; \
  gpg --no-tty --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
  rm -rf "$GNUPGHOME"; \
  apt-key list

ENV PG_MAJOR 16
ENV PG_VERSION 16.4*
ENV C2D_RELEASE 16.4.0

RUN echo 'deb https://apt-archive.postgresql.org/pub/repos/apt bookworm-pgdg-archive main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
  && apt-get install -y postgresql-common \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get install -y \
    postgresql-$PG_MAJOR=$PG_VERSION \
  && rm -rf /var/lib/apt/lists/*

# make the sample config easier to munge (and "correct by default")
RUN mv -v /usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample /usr/share/postgresql/ \
  && ln -sv ../postgresql.conf.sample /usr/share/postgresql/$PG_MAJOR/ \
  && sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod g+s /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh  / \
    && chown root:postgres /docker-entrypoint.sh

# Fix Debian vulnerabilities installing latest packages
RUN apt-get update && \
    apt-get -y install \
      dpkg \
      gzip \
      libc-bin \
      libc-l10n \
      libc6 \
      liblzma5 \
      libpcre2-8-0 \
      libsystemd0 \
      libtasn1-6 \
      libtirpc-common \
      libtirpc3 \
      libudev1 \
      locales \
      zlib1g \
      perl

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
