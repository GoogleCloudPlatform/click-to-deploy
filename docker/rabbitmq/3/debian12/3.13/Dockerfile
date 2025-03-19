FROM marketplace.gcr.io/google/debian12

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.17
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    dirmngr \
    gpg \
		gpg-agent \
    wget \
    openssl && rm -rf /var/lib/apt/lists/* \
  && wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
# copy source code
  && wget -q -O /usr/local/src/gosu.tar.gz "https://github.com/tianon/gosu/archive/$GOSU_VERSION.tar.gz" \
# extract gosu binary and check signature
  && export GNUPGHOME="$(mktemp -d)" \
  && found='' \
  && for server in \
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
    gpg --no-tty --keyserver $server --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      && found="yes" && break; \
  done; test -n "$found" \
  && gpg --no-tty --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y --auto-remove wget

ENV OTP_VERSION 26.2.5.3

# Install dependencies required to build Erlang/OTP from source
# http://erlang.org/doc/installation_guide/INSTALL.html
# autoconf: Required to configure Erlang/OTP before compiling
# dpkg-dev: Required to set up host & build type when compiling Erlang/OTP
# libncurses5-dev: Required for Erlang/OTP new shell & observer_cli - https://github.com/zhongwencool/observer_cli
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    autoconf \
    ca-certificates \
    dirmngr \
    dpkg-dev \
    gcc \
    g++ \
    gnupg \
    libssl-dev \
    libncurses5-dev \
    m4 \
    make \
    openssl \
    wget \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  openssl version; \
  \
  OTP_SOURCE_URL="https://github.com/erlang/otp/archive/OTP-$OTP_VERSION.tar.gz"; \
  OTP_PATH="/usr/local/src/otp-$OTP_VERSION"; \
  \
# Download, verify & extract OTP_SOURCE
  mkdir -p "$OTP_PATH"; \
  wget --progress dot:giga --output-document "$OTP_PATH.tar.gz" "$OTP_SOURCE_URL"; \
  tar --extract --file "$OTP_PATH.tar.gz" --directory "$OTP_PATH" --strip-components 1; \
  \
# Configure Erlang/OTP for compilation, disable unused features & applications
# http://erlang.org/doc/applications.html
# ERL_TOP is required for Erlang/OTP makefiles to find the absolute path for the installation
  cd "$OTP_PATH"; \
  export ERL_TOP="$OTP_PATH"; \
  ./otp_build autoconf; \
  CFLAGS="$(dpkg-buildflags --get CFLAGS)"; export CFLAGS; \
# add -rpath to avoid conflicts between our OpenSSL's "libssl.so" and the libssl package by making sure /usr/local/lib is searched first (but only for Erlang/OpenSSL to avoid issues with other tools using libssl; https://github.com/docker-library/rabbitmq/issues/364)
  export CFLAGS="$CFLAGS -Wl,-rpath=/usr/lib/ssl"; \
  hostArch="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)"; \
  buildArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
  dpkgArch="$(dpkg --print-architecture)"; dpkgArch="${dpkgArch##*-}"; \
  ./configure \
    --host="$hostArch" \
    --build="$buildArch" \
    --disable-dynamic-ssl-lib \
    --disable-hipe \
    --disable-sctp \
    --disable-silent-rules \
    --enable-jit \
    --enable-clock-gettime \
    --enable-hybrid-heap \
    --enable-kernel-poll \
    --enable-shared-zlib \
    --enable-smp-support \
    --enable-threads \
    --with-microstate-accounting=extra \
    --without-common_test \
    --without-debugger \
    --without-dialyzer \
    --without-diameter \
    --without-edoc \
    --without-erl_docgen \
    --without-et \
    --without-eunit \
    --without-ftp \
    --without-hipe \
    --without-jinterface \
    --without-megaco \
    --without-observer \
    --without-odbc \
    --without-reltool \
    --without-ssh \
    --without-tftp \
    --without-wx \
  ; \
# Compile & install Erlang/OTP
  make -j "$(getconf _NPROCESSORS_ONLN)" GEN_OPT_FLGS="-O2 -fno-strict-aliasing"; \
  make install; \
  cd ..; \
  rm -rf \
    "$OTP_PATH"* \
    /usr/local/lib/erlang/lib/*/examples \
    /usr/local/lib/erlang/lib/*/src \
  ; \
  \
# Check that Erlang/OTP crypto & ssl were compiled against OpenSSL correctly
  erl -noshell -eval 'io:format("~p~n~n~p~n~n", [crypto:supports(), ssl:versions()]), init:stop().'

ENV RABBITMQ_DATA_DIR=/var/lib/rabbitmq
# Create rabbitmq system user & group, fix permissions & allow root user to connect to the RabbitMQ Erlang VM
RUN set -eux; \
  groupadd --gid 999 --system rabbitmq; \
  useradd --uid 999 --system --home-dir "$RABBITMQ_DATA_DIR" --gid rabbitmq rabbitmq; \
  mkdir -p "$RABBITMQ_DATA_DIR" /etc/rabbitmq /tmp/rabbitmq-ssl /var/log/rabbitmq /etc/rabbitmq/conf.d; \
  chown -fR rabbitmq:rabbitmq "$RABBITMQ_DATA_DIR" /etc/rabbitmq /tmp/rabbitmq-ssl /var/log/rabbitmq /etc/rabbitmq/conf.d; \
  chmod 777 "$RABBITMQ_DATA_DIR" /etc/rabbitmq /tmp/rabbitmq-ssl /var/log/rabbitmq /etc/rabbitmq/conf.d; \
  ln -sf "$RABBITMQ_DATA_DIR/.erlang.cookie" /root/.erlang.cookie


ENV RABBITMQ_VERSION 3.13.7
ENV RABBITMQ_HOME=/opt/rabbitmq

ENV C2D_RELEASE 3.13.7

# Add RabbitMQ to PATH, send all logs to TTY
ENV PATH=$RABBITMQ_HOME/sbin:$PATH \
  RABBITMQ_LOGS=-

# Install RabbitMQ
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    ca-certificates \
    dirmngr \
    gnupg2 \
    wget \

    xz-utils \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  RABBITMQ_SOURCE_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v$RABBITMQ_VERSION/rabbitmq-server-generic-unix-latest-toolchain-$RABBITMQ_VERSION.tar.xz"; \
  RABBITMQ_PATH="/usr/local/src/rabbitmq-$RABBITMQ_VERSION"; \
  \
  wget --progress dot:giga --output-document "$RABBITMQ_PATH.tar.xz" "$RABBITMQ_SOURCE_URL"; \
  \
  mkdir -p "$RABBITMQ_HOME"; \
  tar --extract --file "$RABBITMQ_PATH.tar.xz" --directory "$RABBITMQ_HOME" --strip-components 1; \
  rm -rf "$RABBITMQ_PATH"*; \
# Do not default SYS_PREFIX to RABBITMQ_HOME, leave it empty
  grep -qE '^SYS_PREFIX=\$\{RABBITMQ_HOME\}$' "$RABBITMQ_HOME/sbin/rabbitmq-defaults"; \
  sed -i 's/^SYS_PREFIX=.*$/SYS_PREFIX=/' "$RABBITMQ_HOME/sbin/rabbitmq-defaults"; \
  grep -qE '^SYS_PREFIX=$' "$RABBITMQ_HOME/sbin/rabbitmq-defaults"; \
  chown -R rabbitmq:rabbitmq "$RABBITMQ_HOME"; \
  \
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
  find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  ; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
# verify assumption of no stale cookies
  [ ! -e "$RABBITMQ_DATA_DIR/.erlang.cookie" ]

RUN apt update && apt install -y openssl

# Ensure RabbitMQ was installed correctly by running a few commands that do not depend on a running server, as the rabbitmq user
# If they all succeed, it's safe to assume that things have been set up correctly
RUN	gosu rabbitmq rabbitmqctl help; \
  gosu rabbitmq rabbitmqctl list_ciphers; \
  gosu rabbitmq rabbitmq-plugins list; \
# no stale cookies
  rm "$RABBITMQ_DATA_DIR/.erlang.cookie"

# Enable Prometheus-style metrics by default (https://github.com/docker-library/rabbitmq/issues/419)
RUN set -eux; \
	gosu rabbitmq rabbitmq-plugins enable --offline rabbitmq_prometheus; \
	echo 'management_agent.disable_metrics_collector = true' > /etc/rabbitmq/conf.d/management_agent.disable_metrics_collector.conf; \
	chown rabbitmq:rabbitmq /etc/rabbitmq/conf.d/management_agent.disable_metrics_collector.conf

# Added for backwards compatibility - users can simply COPY custom plugins to /plugins
RUN ln -sf /opt/rabbitmq/plugins /plugins

# set home so that any `--user` knows where to put the erlang cookie
ENV HOME $RABBITMQ_DATA_DIR
# Hint that the data (a.k.a. home dir) dir should be separate volume
VOLUME $RABBITMQ_DATA_DIR

# warning: the VM is running with native name encoding of latin1 which may cause Elixir to malfunction as it expects utf8. Please ensure your locale is set to UTF-8 (which can be verified by running "locale" in your shell)
# Setting all environment variables that control language preferences, behaviour differs - https://www.gnu.org/software/gettext/manual/html_node/The-LANGUAGE-variable.html#The-LANGUAGE-variable
# https://docs.docker.com/samples/library/ubuntu/#locales
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

COPY --chown=rabbitmq:rabbitmq docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 4369 5671 5672 25672
CMD ["rabbitmq-server"]
