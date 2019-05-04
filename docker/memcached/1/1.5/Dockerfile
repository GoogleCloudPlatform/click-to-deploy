FROM gcr.io/google-appengine/debian9 as memcached-builder
ENV MEMCACHED_VERSION 1.5.13
ENV MEMCACHED_SHA1 f0ddd566a55fdc5397d458cf3b3806b5cb48bb18

RUN set -x \
	&& buildDeps=' \
		ca-certificates \
		dpkg-dev \
		gcc \
		libc6-dev \
		libevent-dev \
		libsasl2-dev \
		make \
		perl \
		wget \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/memcached_build \
	&& mkdir -p /usr/src/memcached \
	&& cd /usr/src/memcached \
	&& wget -O memcached.tar.gz "https://memcached.org/files/memcached-$MEMCACHED_VERSION.tar.gz" \
	&& echo "$MEMCACHED_SHA1  memcached.tar.gz" | sha1sum -c - \
	&& tar -xzf memcached.tar.gz -C /usr/src/memcached_build --strip-components=1 \
	&& cd /usr/src/memcached_build \
	&& ./configure \
		--build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
		--enable-sasl \
	&& make -j "$(nproc)" \
	&& make install \
	&& apt-mark manual \
		libevent-2.0-5 \
		libsasl2-2 \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& memcached -V

FROM gcr.io/google-appengine/debian9 as prometheus-builder

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r memcache && useradd -r -g memcache memcache

COPY --from=memcached-builder /usr/local/bin/memcached /usr/local/bin/memcached

RUN apt-get update && apt-get install git gcc make curl wget tar libevent-2.0-5 libsasl2-2 -y
RUN git clone https://github.com/prometheus/memcached_exporter /memcached_exporter
RUN wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz && \
      tar -C /usr/local -zxvf go1.12.linux-amd64.tar.gz

RUN cd /memcached_exporter && \
			export PATH=$PATH:/usr/local/go/bin && \
			git checkout 1454051534ec5b9c65201907b4c90cabbd862185 && \
			memcached -u memcache -d && \
      make
RUN cd /memcached_exporter && \
      wget -O LICENSE.protobuf.gogo https://raw.githubusercontent.com/gogo/protobuf/v1.1.1/LICENSE
FROM gcr.io/google-appengine/debian9

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r memcache && useradd -r -g memcache memcache

COPY --from=memcached-builder /usr/local/bin/memcached /usr/local/bin/memcached
COPY --from=memcached-builder /usr/src/memcached_build/COPYING /opt/memcached/COPYING
COPY --from=memcached-builder /usr/src/memcached_build/LICENSE.bipbuffer /opt/memcached/LICENSE.bipbuffer
COPY --from=prometheus-builder /memcached_exporter/memcached_exporter /usr/local/bin/memcached_exporter
COPY --from=prometheus-builder /memcached_exporter/LICENSE /opt/memcached_exporter/LICENSE
COPY --from=prometheus-builder /memcached_exporter/LICENSE.protobuf.gogo /opt/memcached_exporter/LICENSE.protobuf.gogo
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/konsorten/go-windows-terminal-sequences/LICENSE /opt/memcached_exporter/LICENSE.go-windows-terminal-sequences.konsorten
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/prometheus/client_golang/LICENSE /opt/memcached_exporter/LICENSE.client_golang.prometheus
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/prometheus/client_model/LICENSE /opt/memcached_exporter/LICENSE.client_model.prometheus
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/prometheus/common/LICENSE /opt/memcached_exporter/LICENSE.common.prometheus
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/prometheus/procfs/LICENSE /opt/memcached_exporter/LICENSE.procfs.prometheus
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/sirupsen/logrus/LICENSE /opt/memcached_exporter/LICENSE.logrus.sirupsen
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/alecthomas/template/LICENSE /opt/memcached_exporter/LICENSE.template.alecthomas
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/beorn7/perks/LICENSE /opt/memcached_exporter/LICENSE.perks.beorn7
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/grobie/gomemcache/LICENSE /opt/memcached_exporter/LICENSE.gomemcache.grobie
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/golang/protobuf/LICENSE /opt/memcached_exporter/LICENSE.protobuf.golang
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/matttproud/golang_protobuf_extensions/LICENSE /opt/memcached_exporter/LICENSE.golang_protobuf_extensions.matttproud
COPY --from=prometheus-builder /memcached_exporter/vendor/golang.org/x/sys/LICENSE /opt/memcached_exporter/LICENSE.sys.x
COPY --from=prometheus-builder /memcached_exporter/vendor/golang.org/x/crypto/LICENSE /opt/memcached_exporter/LICENSE.crypto.x
COPY --from=prometheus-builder /memcached_exporter/vendor/github.com/alecthomas/units/COPYING /opt/memcached_exporter/COPYING.units.alecthomas
COPY --from=prometheus-builder /memcached_exporter/vendor/gopkg.in/alecthomas/kingpin.v2/COPYING /opt/memcached_exporter/COPYING.kingpin.v2.alecthomas

COPY docker-entrypoint.sh /usr/local/bin/
RUN apt-get update && apt-get install -y \
      libevent-2.0-5 libsasl2-2 --no-install-recommends && \
		  rm -rf /var/lib/apt/lists/*
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

USER memcache
EXPOSE 9150 11211
CMD ["memcached"]
