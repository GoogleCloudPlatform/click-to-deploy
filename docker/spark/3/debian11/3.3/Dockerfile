FROM marketplace.gcr.io/google/debian11 AS builder

# Add Java 11
RUN apt-get update \
  && apt-get install -y \
    openjdk-11-jdk \
    wget

# Download and uncompress spark from the apache/spark github
RUN wget --no-verbose -O apache-spark.tgz "https://github.com/apache/spark/archive/refs/tags/v3.3.0-rc2.tar.gz" \
      && mkdir -p /opt/spark \
      && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
      && rm apache-spark.tgz

WORKDIR /opt/spark

# Build a Runnable Distribution
RUN ./build/mvn -Pyarn -Dhadoop.version=3.3.0 -DskipTests clean package

FROM marketplace.gcr.io/google/debian11

# Add Java 11
RUN apt-get update \
  && apt-get install -y \
    openjdk-11-jdk

# Add Dependencies for PySpark
RUN apt-get install -y \
    curl \
    vim \
    wget \
    software-properties-common \
    ssh \
    net-tools \
    ca-certificates \
    python3 \
    python3-pip \
    python3-numpy \
    python3-matplotlib \
    python3-scipy \
    python3-pandas \
    python3-sympy

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=v3.3.0-rc2
ENV HADOOP_VERSION=3.3.0
ENV SPARK_HOME=/opt/spark
ENV PYTHONHASHSEED=1

WORKDIR /opt/spark

COPY --from=builder /opt/spark .

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

RUN echo "spark.eventLog.logStageExecutorMetrics=true" >> /opt/spark/conf/spark-defaults.conf \
      && echo "spark.ui.prometheus.enabled=true" >> /opt/spark/conf/spark-defaults.conf

CMD ["/bin/bash", "/start-spark.sh"]
