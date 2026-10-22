FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7

# Get the list of packages from the base image.

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
			openssl \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
		ca-certificates \
		dirmngr \
		wget \
	&& apt-get install -y --only-upgrade \
		libpcre2-8-0 \
		perl \
		perl-base \
		zlib1g \
	&& rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root and build from source to avoid Go vulnerabilities
ENV GOSU_VERSION 1.19

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
		git \
	; \
	# Install a secure Go version
	wget -qO- https://go.dev/dl/go1.26.10.linux-amd64.tar.gz | tar -C /usr/local -xzf -; \
	export PATH=$PATH:/usr/local/go/bin; \
	# Compile gosu
	git clone --depth 1 -b "$GOSU_VERSION" https://github.com/tianon/gosu.git /usr/local/src/gosu; \
	cd /usr/local/src/gosu; \
	go get github.com/moby/sys/user@v0.4.1; \
	go mod tidy; \
	go build -ldflags '-w -s' -o /usr/local/bin/gosu; \
	# Test gosu runs and clean up build dependencies
	/usr/local/bin/gosu nobody true; \
	rm -rf /usr/local/go /usr/local/src/gosu /root/.cache /root/go; \
	apt-get purge -y --auto-remove git; \
	rm -rf /var/lib/apt/lists/*

# Install Redis Search
ENV REDIS_VERSION 7.2.4
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-7.2.4.tar.gz

ENV C2D_RELEASE=${REDIS_VERSION}

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN set -ex \
	\
	&& buildDeps=' \
		gcc \
		libc6-dev \
		libssl-dev \
		dpkg-dev \
		make \
	' \
	&& apt-get update \
	&& apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& wget -q -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
	&& mkdir -p /usr/local/src/redis \
	&& tar -xzf redis.tar.gz -C /usr/local/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	\
	&& make -C /usr/local/src/redis \
	&& make -C /usr/local/src/redis install \
	\
	&& rm -r /usr/local/src/redis \
	\
	&& apt-get purge -y --auto-remove $buildDeps

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

# Copy BSD License
RUN mkdir -p /usr/share/redis
COPY LICENSE /usr/share/redis/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD [ "redis-server" ]
