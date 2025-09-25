# Build gosu from the source. As by 2023-09-26 project only have releases
# from go 1.18. https://github.com/tianon/gosu/releases
ARG BASE_REGISTRY="docker.io"
FROM docker.io/golang as gosu-build

RUN git clone https://github.com/tianon/gosu.git --branch 1.17 /go/src/github.com/tianon/gosu

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		arch-test \
		file \
		patch \
	; \
	rm -rf /var/lib/apt/lists/*

# note: we cannot add "-s" here because then "govulncheck" does not work (see SECURITY.md); the ~0.2MiB increase (as of 2022-12-16, Go 1.18) is worth it
ENV BUILD_FLAGS="-v -ldflags '-d -w'"

RUN set -eux; \
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail -x'; \
		echo 'eval "go build $BUILD_FLAGS -o /go/bin/gosu-$ARCH"'; \
		echo 'file "/go/bin/gosu-$ARCH"'; \
		echo 'if arch-test "$ARCH"; then'; \
# there's a fun QEMU + Go 1.18+ bug that causes our binaries (especially on ARM arches) to hang indefinitely *sometimes*, hence the "timeout" and looping here
		echo '  try() { for (( i = 0; i < 30; i++ )); do if timeout 1s "$@"; then return 0; fi; done; return 1; }'; \
		echo '  try "/go/bin/gosu-$ARCH" --version'; \
		echo '  try "/go/bin/gosu-$ARCH" nobody id'; \
		echo '  try "/go/bin/gosu-$ARCH" nobody ls -l /proc/self/fd'; \
		echo 'fi'; \
	} > /usr/local/bin/gosu-build-and-test.sh; \
	chmod +x /usr/local/bin/gosu-build-and-test.sh

# disable CGO for ALL THE THINGS (to help ensure no libc)
ENV CGO_ENABLED 0

WORKDIR /go/src/github.com/tianon/gosu

RUN set -eux; \
	go mod download; \
	go mod verify

# gosu-$(dpkg --print-architecture)
RUN ARCH=amd64    GOARCH=amd64       gosu-build-and-test.sh
RUN set -eux; ls -lAFh /go/bin/gosu-*; file /go/bin/gosu-*

FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

ENV C2D_RELEASE 11.5.2

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql


ARG GPG_KEYS=177F4010FE56CA3336300305F1656F24C74CD1D8
# pub   rsa4096 2016-03-30 [SC]
#         177F 4010 FE56 CA33 3630  0305 F165 6F24 C74C D1D8
# uid           [ unknown] MariaDB Signing Key <signing-key@mariadb.org>
# sub   rsa4096 2016-03-30 [E]
# install "libjemalloc2" as it offers better performance in some cases. Use with LD_PRELOAD
# install "pwgen" for randomizing passwords
# install "tzdata" for /usr/share/zoneinfo/
# install "xz-utils" for .sql.xz docker-entrypoint-initdb.d files
# install "zstd" for .sql.zst docker-entrypoint-initdb.d files
# hadolint ignore=SC2086
RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		gpg \
		gpgv \
		libjemalloc2 \
		pwgen \
		tzdata \
		xz-utils \
		zstd ; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get install -y --no-install-recommends \
		dirmngr \
		gpg-agent \
		wget; \
	rm -rf /var/lib/apt/lists/*; \
	GNUPGHOME="$(mktemp -d)"; \
	export GNUPGHOME; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	for key in $GPG_KEYS; do \
		gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	done; \
	gpg --batch --export "$GPG_KEYS" > /etc/apt/trusted.gpg.d/mariadb.gpg; \
	if command -v gpgconf >/dev/null; then \
		gpgconf --kill all; \
	fi; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] ||	apt-mark manual $savedAptMark >/dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# add gosu for easy step-down from root
COPY --from=gosu-build /go/bin/gosu-amd64 /usr/local/bin/gosu
RUN gosu --version && gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

# Ensure the container exec commands handle range of utf8 characters based of
# default locales in base image (https://github.com/docker-library/docs/blob/135b79cc8093ab02e55debb61fdb079ab2dbce87/ubuntu/README.md#locales)
ENV LANG C.UTF-8



# bashbrew-architectures: amd64 arm64v8 ppc64le s390x
ARG MARIADB_VERSION=1:11.5.2+maria~deb12
ENV MARIADB_VERSION $MARIADB_VERSION
# release-status:Alpha
# release-support-type:Unknown
# (https://downloads.mariadb.org/rest-api/mariadb/)

# Allowing overriding of REPOSITORY, a URL that includes suite and component for testing and Enterprise Versions
ARG REPOSITORY="http://archive.mariadb.org/mariadb-11.5.2/repo/debian/ bookworm main"

RUN set -e;\
	echo "deb ${REPOSITORY}" > /etc/apt/sources.list.d/mariadb.list; \
	{ \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
	} > /etc/apt/preferences.d/mariadb

# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
#  libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
# hadolint ignore=DL3015
RUN set -ex; \
	{ \
		echo "mariadb-server" mysql-server/root_password password 'unused'; \
		echo "mariadb-server" mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections; \
	apt-get update; \
# postinst script creates a datadir, so avoid creating it by faking its existance.
	mkdir -p /var/lib/mysql/mysql ; touch /var/lib/mysql/mysql/user.frm ; \
# mariadb-backup is installed at the same time so that `mysql-common` is only installed once from just mariadb repos
	apt-get install -y --no-install-recommends \
		mariadb-server="$MARIADB_VERSION" \
		mariadb-client="$MARIADB_VERSION" \
		mariadb-client-core="$MARIADB_VERSION" \
		mariadb-server-core="$MARIADB_VERSION" \
		mariadb-backup="$MARIADB_VERSION" \
		socat \
	; \
	rm -rf /var/lib/apt/lists/*; \
# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf; \
	mkdir -p /var/lib/mysql /var/run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /var/run/mysqld; \
# comment out a few problematic configuration values
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log|user\s)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/'; \
# don't reverse lookup hostnames, they are usually another container
	printf "[mariadb]\nhost-cache-size=0\nskip-name-resolve\n" > /etc/mysql/mariadb.conf.d/05-skipcache.cnf; \
# Issue #327 Correct order of reading directories /etc/mysql/mariadb.conf.d before /etc/mysql/conf.d (mount-point per documentation)
	if [ -L /etc/mysql/my.cnf ]; then \
# 10.5+
		sed -i -e '/includedir/ {N;s/\(.*\)\n\(.*\)/\n\2\n\1/}' /etc/mysql/mariadb.cnf; \
	fi


VOLUME /var/lib/mysql

COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mariadbd"]
