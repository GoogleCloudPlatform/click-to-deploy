FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get --allow-releaseinfo-change update && apt-get install -y --no-install-recommends gnupg dirmngr && rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
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

RUN mkdir /docker-entrypoint-initdb.d

RUN set -eux; \
	apt-get --allow-releaseinfo-change update; \
	apt-get install -y --no-install-recommends \
    pwgen \
		openssl \
# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
		perl \
		xz-utils \
		zstd \
    libtasn1-6 \
	; \
	apt-get install -y --only-upgrade perl zlib1g; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
# gpg: key 3A79BD29: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='BCA4 3417 C3B4 85DD 128E C6D4 B7B3 B788 A8D3 785C'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	mkdir -p /etc/apt/keyrings; \
	gpg --batch --export "$key" > /etc/apt/keyrings/mysql.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"

ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.46-1debian12
ENV C2D_RELEASE 8.0.46

RUN echo "deb [ signed-by=/etc/apt/keyrings/mysql.gpg ] http://repo.mysql.com/apt/debian/  bookworm  mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN { \
    echo mysql-community-server mysql-community-server/data-dir select ''; \
    echo mysql-community-server mysql-community-server/root-pass password ''; \
    echo mysql-community-server mysql-community-server/re-root-pass password ''; \
    echo mysql-community-server mysql-community-server/remove-test-db select false; \
  } | debconf-set-selections \
  && apt-get --allow-releaseinfo-change update \
	&& apt-get install -y \
    	mysql-community-client="${MYSQL_VERSION}" \
		  mysql-community-server-core="${MYSQL_VERSION}" \
  && rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	&& chmod 1777 /var/run/mysqld /var/lib/mysql

VOLUME /var/lib/mysql
# Config files
COPY config/ /etc/mysql/

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh  # for backwards compatibility
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
