FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

ENV C2D_RELEASE 4.0.4

# Add Java JDK
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    ca-certificates \
    curl \
    software-properties-common \
    ssh \
    net-tools \
    python3 \
    python3-pip \
    python3-numpy \
    python3-matplotlib \
    python3-scipy \
    python3-pandas \
    python3-sympy \
    supervisor \
    vim \
    wget \
  && apt-get install -y --only-upgrade perl zlib1g libnss3 \
  && apt-get purge -y python3-pil \
  && pip3 install --no-cache-dir --upgrade pillow --break-system-packages \
  && rm -rf /var/lib/apt/lists/*
  
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=4.0.4
ENV SCALA_VERSION=2.13
ENV SPARK_HOME=/opt/spark
ENV PYTHONHASHSEED=1

# Download and uncompress spark from the apache archive using parallel byte-range requests
RUN set -ex; \
  url="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz"; \
  size=$(curl -sIL "$url" | awk 'tolower($1)=="content-length:" {size=$2} END {gsub(/\r/,"",size); print size}'); \
  if [ -n "$size" ] && [ "$size" -gt 0 ]; then \
    chunk=$(( (size + 127) / 128 )); \
    seq 0 127 | xargs -P 64 -I {} sh -c ' \
      i={}; start=$(( i * '"$chunk"' )); end=$(( start + '"$chunk"' - 1 )); \
      if [ "$end" -ge "'"$size"'" ]; then end=$(( '"$size"' - 1 )); fi; \
      if [ "$start" -le "$end" ]; then \
        curl --retry 5 --retry-all-errors -sfL -r "${start}-${end}" "'"$url"'" -o "/tmp/spark.tgz.part.$(printf "%03d" "$i")"; \
      fi \
    '; \
    cat /tmp/spark.tgz.part.* > apache-spark.tgz; \
    rm -f /tmp/spark.tgz.part.*; \
  else \
    curl --retry 5 -fL -o apache-spark.tgz "$url"; \
  fi; \
  mkdir -p /opt/spark; \
  tar -xf apache-spark.tgz -C /opt/spark --strip-components=1; \
  rm -f apache-spark.tgz

# Patch ZooKeeper, BouncyCastle, Netty, Avro, and Jetty CVEs
RUN set -ex; \
  rm -f /opt/spark/jars/zookeeper-*.jar; \
  for mod in zookeeper zookeeper-jute zookeeper-prometheus-metrics; do \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/apache/zookeeper/${mod}/3.9.5/${mod}-3.9.5.jar" \
      -o "/opt/spark/jars/${mod}-3.9.5.jar"; \
  done; \
  if ls /opt/spark/jars/bcprov-jdk18on-*.jar >/dev/null 2>&1; then \
    rm -f /opt/spark/jars/bcprov-jdk18on-*.jar; \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/1.86/bcprov-jdk18on-1.86.jar" \
      -o "/opt/spark/jars/bcprov-jdk18on-1.86.jar"; \
  fi; \
  for f in /opt/spark/jars/netty-*-4.1.*.Final*.jar; do \
    [ -e "$f" ] || continue; \
    bn=$(basename "$f"); \
    art=$(echo "$bn" | sed -E 's/-4\.1\.[0-9]+\.Final.*//'); \
    suf=$(echo "$bn" | sed -E 's/^netty-.*-4\.1\.[0-9]+\.Final(.*)\.jar$/\1/'); \
    rm -f "$f"; \
    curl --retry 5 -sfL "https://repo1.maven.org/maven2/io/netty/${art}/4.1.139.Final/${art}-4.1.139.Final${suf}.jar" \
      -o "/opt/spark/jars/${art}-4.1.139.Final${suf}.jar"; \
  done; \
  mkdir -p /tmp/jar-patch && cd /tmp/jar-patch; \
  for jar in /opt/spark/jars/hadoop-client-runtime-*.jar /opt/spark/jars/spark-core_*.jar /opt/spark/yarn/spark-*-yarn-shuffle.jar /opt/spark/jars/connect-repl/spark-connect-client-jvm_*.jar; do \
    [ -e "$jar" ] || continue; \
    rm -rf /tmp/jar-patch/*; \
    jar xf "$jar" META-INF/maven; \
    if [ -d META-INF/maven ]; then \
      find META-INF/maven -path "*/io.netty/*" -type f \( -name "pom.properties" -o -name "pom.xml" \) \
        -exec sed -i -E 's/4\.1\.[0-9]+\.Final/4.1.139.Final/g' {} +; \
      find META-INF/maven -path "*/org.apache.avro/*" -type f \( -name "pom.properties" -o -name "pom.xml" \) \
        -exec sed -i -E 's/1\.[79]\.[0-9]+/1.11.5/g' {} +; \
      find META-INF/maven -path "*/org.eclipse.jetty*" -type f \( -name "pom.properties" -o -name "pom.xml" \) \
        -exec sed -i -E -e 's/9\.4\.[0-9]+\.v[0-9]+/9.4.63.v20260201/g' -e 's/11\.0\.[0-9]+/11.0.31/g' {} +; \
      jar uf "$jar" META-INF/maven; \
    fi; \
  done; \
  cd / && rm -rf /tmp/jar-patch

WORKDIR /opt/spark

ENV SPARK_MASTER_PORT=7077
ENV SPARK_MASTER_WEBUI_PORT=8080
ENV SPARK_LOG_DIR=/opt/spark/logs
ENV SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out
ENV SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out
ENV SPARK_WORKER_WEBUI_PORT=8080
ENV SPARK_WORKER_PORT=7000
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_WORKLOAD="master"

EXPOSE 8080 7077 6066

RUN mkdir -p $SPARK_LOG_DIR \
  && touch $SPARK_MASTER_LOG \
  && touch $SPARK_WORKER_LOG \
  && ln -sf /dev/stdout $SPARK_MASTER_LOG \
  && ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark.sh /
COPY metrics.properties /opt/spark/conf/metrics.properties
COPY test_job.py /opt/spark-apps/test_job.py
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

WORKDIR /opt/spark

ENTRYPOINT [ "/start-spark.sh" ]
