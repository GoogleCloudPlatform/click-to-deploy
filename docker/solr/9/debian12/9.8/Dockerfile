FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install ca-certificates curl

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
		&& sed -i 's/curl -sL/curl -sL --connect-timeout 5 --max-time 10/g' /download-licenses.sh \
		&& chmod +x /download-licenses.sh \
		&& chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses \
		&& /download-ref-repos.sh /source_code.txt /usr/src

FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

COPY --from=ospo /usr/src /usr/src

ARG SOLR_VERSION=9.8.1
ARG SOLR_KEYS=50E3EE1C91C7E0CB4DFB007B369424FC98F3F6EC

ENV C2D_RELEASE=9.8.1

RUN set -ex; \
  apt-get update; \
  apt-get -y install default-jdk acl dirmngr gpg lsof procps wget curl netcat-traditional tini; \
  apt-get install -y --only-upgrade perl zlib1g; \
  echo "deb http://deb.debian.org/debian trixie main" > /etc/apt/sources.list.d/trixie.list; \
  apt-get update; \
  apt-get install -y --only-upgrade libbrotli1; \
  rm -f /etc/apt/sources.list.d/trixie.list; \
  rm -rf /var/lib/apt/lists/*; \
  cd /usr/local/bin; wget -nv https://github.com/apangin/jattach/releases/download/v1.5/jattach; chmod 755 jattach; \
  echo >jattach.sha512 "d8eedbb3e192a8596c08efedff99b9acf1075331e1747107c07cdb1718db2abe259ef168109e46bd4cf80d47d43028ff469f95e6ddcbdda4d7ffa73a20e852f9  jattach"; \
  sha512sum -c jattach.sha512; rm jattach.sha512

ENV SOLR_USER="solr" \
    SOLR_UID="8983" \
    SOLR_GROUP="solr" \
    SOLR_GID="8983" \
    SOLR_CLOSER_URL="http://www.apache.org/dyn/closer.lua?action=download&filename=/solr/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    SOLR_DIST_URL="https://www.apache.org/dist/solr/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    SOLR_ARCHIVE_URL="https://archive.apache.org/dist/solr/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    PATH="/opt/solr/bin:/opt/solr/docker/scripts:/opt/solr/prometheus-exporter/bin:$PATH" \
    SOLR_INCLUDE=/etc/default/solr.in.sh \
    SOLR_HOME=/var/solr/data \
    SOLR_PID_DIR=/var/solr \
    SOLR_LOGS_DIR=/var/solr/logs \
    LOG4J_PROPS=/var/solr/log4j2.xml \
    SOLR_SERVER_DIR=/opt/solr/server \
    SOLR_JETTY_HOST="0.0.0.0"

# Workaround for CVE-2021-44228
# https://www.docker.com/blog/apache-log4j-2-cve-2021-44228/
ENV JAVA_OPTS="-Dlog4j.formatMsgNoLookups=true"

RUN set -ex; \
  groupadd -r --gid "$SOLR_GID" "$SOLR_GROUP"; \
  useradd -r --uid "$SOLR_UID" --gid "$SOLR_GID" "$SOLR_USER"

RUN set -ex; \
  export GNUPGHOME="/tmp/gnupg_home"; \
  mkdir -p "$GNUPGHOME"; \
  chmod 700 "$GNUPGHOME"; \
  echo "disable-ipv6" >> "$GNUPGHOME/dirmngr.conf"; \
  found='' && \
	for server in \
		pool.sks-keyservers.net \
		na.pool.sks-keyservers.net \
		eu.pool.sks-keyservers.net \
		oc.pool.sks-keyservers.net \
		ha.pool.sks-keyservers.net \
		hkp://p80.pool.sks-keyservers.net:80 \
		hkp://keyserver.ubuntu.com:80 \
		pgp.mit.edu \
	; do \
		gpg --no-tty --keyserver $server --recv-keys $SOLR_KEYS \
			&& found=yes && break; \
	done; \
	test -n "$found" \
  && exit 0

RUN set -ex; \
  export GNUPGHOME="/tmp/gnupg_home"; \
  echo "downloading $SOLR_ARCHIVE_URL"; \
  size=$(curl -sIL "$SOLR_ARCHIVE_URL" | awk 'tolower($1)=="content-length:" {size=$2} END {gsub(/\r/,"",size); print size}'); \
  if [ -n "$size" ] && [ "$size" -gt 0 ]; then \
    chunk=$(( (size + 127) / 128 )); \
    seq 0 127 | xargs -P 64 -I {} sh -c ' \
      i={}; start=$(( i * '"$chunk"' )); end=$(( start + '"$chunk"' - 1 )); \
      if [ "$end" -ge "'"$size"'" ]; then end=$(( '"$size"' - 1 )); fi; \
      if [ "$start" -le "$end" ]; then \
        curl --retry 5 --retry-all-errors -sfL -r "${start}-${end}" "'"$SOLR_ARCHIVE_URL"'" -o "/opt/solr.tgz.part.$(printf "%03d" "$i")"; \
      fi \
    '; \
    cat /opt/solr.tgz.part.* > "/opt/solr-$SOLR_VERSION.tgz"; \
    rm -f /opt/solr.tgz.part.*; \
  else \
    curl --retry 5 -fL "$SOLR_ARCHIVE_URL" -o "/opt/solr-$SOLR_VERSION.tgz"; \
  fi; \
  echo "downloading $SOLR_ARCHIVE_URL.asc"; \
  wget -nv "$SOLR_ARCHIVE_URL.asc" -O "/opt/solr-$SOLR_VERSION.tgz.asc"; \
    (>&2 ls -l "/opt/solr-$SOLR_VERSION.tgz" "/opt/solr-$SOLR_VERSION.tgz.asc"); \
  gpg --batch --verify "/opt/solr-$SOLR_VERSION.tgz.asc" "/opt/solr-$SOLR_VERSION.tgz"; \
  tar -C /opt --extract --preserve-permissions --file "/opt/solr-$SOLR_VERSION.tgz"; \
  (cd /opt; ln -s "solr-$SOLR_VERSION" solr); \
  rm "/opt/solr-$SOLR_VERSION.tgz"*; \
  rm -Rf /opt/solr/docs/ /opt/solr/docker/Dockerfile; \
  rm -f /opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/netty-*-4.1.*.Final*.jar; \
  for mod in netty-buffer netty-codec netty-common netty-handler netty-resolver netty-transport netty-transport-classes-epoll netty-transport-native-unix-common; do \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/io/netty/${mod}/4.1.139.Final/${mod}-4.1.139.Final.jar" \
      -o "/opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/${mod}-4.1.139.Final.jar"; \
  done; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/io/netty/netty-transport-native-epoll/4.1.139.Final/netty-transport-native-epoll-4.1.139.Final-linux-x86_64.jar" \
    -o "/opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/netty-transport-native-epoll-4.1.139.Final-linux-x86_64.jar"; \
  rm -f /opt/solr-$SOLR_VERSION/modules/opentelemetry/lib/netty-*-4.1.*.Final.jar; \
  for mod in netty-codec-http netty-codec-http2 netty-codec-socks netty-handler-proxy; do \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/io/netty/${mod}/4.1.139.Final/${mod}-4.1.139.Final.jar" \
      -o "/opt/solr-$SOLR_VERSION/modules/opentelemetry/lib/${mod}-4.1.139.Final.jar"; \
  done; \
  rm -f /opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/jersey-*-3.1.*.jar; \
  for pkg in core/jersey-client core/jersey-common core/jersey-server ext/jersey-entity-filtering inject/jersey-hk2 media/jersey-media-json-jackson; do \
    name=$(basename "$pkg"); \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/glassfish/jersey/${pkg}/3.1.12/${name}-3.1.12.jar" \
      -o "/opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/${name}-3.1.12.jar"; \
  done; \
  rm -f /opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/zookeeper-3.9.*.jar /opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/zookeeper-jute-3.9.*.jar; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper/3.9.5/zookeeper-3.9.5.jar" \
    -o "/opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/zookeeper-3.9.5.jar"; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper-jute/3.9.5/zookeeper-jute-3.9.5.jar" \
    -o "/opt/solr-$SOLR_VERSION/server/solr-webapp/webapp/WEB-INF/lib/zookeeper-jute-3.9.5.jar"; \
  for dir in analysis-extras extraction langid; do \
    rm -f "/opt/solr-$SOLR_VERSION/modules/${dir}/lib/opennlp-tools-"*.jar; \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/opennlp/opennlp-tools/2.5.12/opennlp-tools-2.5.12.jar" \
      -o "/opt/solr-$SOLR_VERSION/modules/${dir}/lib/opennlp-tools-2.5.12.jar"; \
  done; \
  for dir in extraction langid; do \
    rm -f "/opt/solr-$SOLR_VERSION/modules/${dir}/lib/tika-core-"*.jar; \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/tika/tika-core/3.3.3/tika-core-3.3.3.jar" \
      -o "/opt/solr-$SOLR_VERSION/modules/${dir}/lib/tika-core-3.3.3.jar"; \
  done; \
  rm -f "/opt/solr-$SOLR_VERSION/modules/extraction/lib/tika-parsers-"*.jar; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/tika/tika-parsers-standard-package/3.3.3/tika-parsers-standard-package-3.3.3.jar" \
    -o "/opt/solr-$SOLR_VERSION/modules/extraction/lib/tika-parsers-standard-package-3.3.3.jar"; \
  rm -f "/opt/solr-$SOLR_VERSION/modules/extraction/lib/mchange-commons-java-"*.jar; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/com/mchange/mchange-commons-java/0.4.0/mchange-commons-java-0.4.0.jar" \
    -o "/opt/solr-$SOLR_VERSION/modules/extraction/lib/mchange-commons-java-0.4.0.jar"; \
  rm -f "/opt/solr-$SOLR_VERSION/modules/hdfs/lib/hadoop-client-api-"*.jar "/opt/solr-$SOLR_VERSION/modules/hdfs/lib/hadoop-client-runtime-"*.jar; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-api/3.5.0/hadoop-client-api-3.5.0.jar" \
    -o "/opt/solr-$SOLR_VERSION/modules/hdfs/lib/hadoop-client-api-3.5.0.jar"; \
  curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-runtime/3.5.0/hadoop-client-runtime-3.5.0.jar" \
    -o "/opt/solr-$SOLR_VERSION/modules/hdfs/lib/hadoop-client-runtime-3.5.0.jar"; \
  mkdir -p /opt/solr/server/solr/lib /docker-entrypoint-initdb.d; \
  chown -R $SOLR_USER:$SOLR_GROUP "/opt/solr-$SOLR_VERSION"; \
  find "/opt/solr-$SOLR_VERSION" -type d -print0 | xargs -0 chmod 0755; \
  find "/opt/solr-$SOLR_VERSION" -type f -print0 | xargs -0 chmod 0644; \
  chmod -R 0755 "/opt/solr-$SOLR_VERSION/bin" "/opt/solr-$SOLR_VERSION/docker/scripts" "/opt/solr-$SOLR_VERSION/prometheus-exporter/bin/solr-exporter" /opt/solr-$SOLR_VERSION/server/scripts/cloud-scripts; \
  cp /opt/solr/bin/solr.in.sh /etc/default/solr.in.sh; \
  mv /opt/solr/bin/solr.in.sh /opt/solr/bin/solr.in.sh.orig; \
  mv /opt/solr/bin/solr.in.cmd /opt/solr/bin/solr.in.cmd.orig; \
  chown $SOLR_USER:$SOLR_GROUP /etc/default/solr.in.sh; \
  chmod 0664 /etc/default/solr.in.sh; \
  mkdir -p /var/solr/data /var/solr/logs; \
  (cd /opt/solr/server/solr; cp solr.xml zoo.cfg /var/solr/data/); \
  cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml; \
  find /var/solr -type d -print0 | xargs -0 chmod 0770; \
  find /var/solr -type f -print0 | xargs -0 chmod 0660; \
  chown -R "$SOLR_USER:$SOLR_GROUP" /opt/solr-$SOLR_VERSION /docker-entrypoint-initdb.d; \
  chown -R "$SOLR_USER:$SOLR_GROUP" /var/solr; \
  ln -s /opt/solr/modules /opt/solr/contrib; \
  ln -s /opt/solr/prometheus-exporter /opt/solr/modules/prometheus-exporter; \
  { command -v gpgconf; gpgconf --kill all || :; }; \
  rm -r "$GNUPGHOME"

VOLUME /var/solr
EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER

RUN ls -lh /opt/solr/docker/scripts
RUN echo $PATH && which docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground"]
