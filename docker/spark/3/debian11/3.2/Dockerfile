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
ENV SPARK_VERSION=3.2.1
ENV HADOOP_VERSION=3.2
ENV SPARK_HOME=/opt/spark
ENV PYTHONHASHSEED=1

# Download and uncompress spark from the apache archive
RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
      && mkdir -p /opt/spark \
      && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
      && rm apache-spark.tgz

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

CMD ["/bin/bash", "/start-spark.sh"]
