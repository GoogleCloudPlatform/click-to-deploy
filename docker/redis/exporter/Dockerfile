FROM marketplace.gcr.io/google/debian12

ENV EXPORTER_VERSION 1.63.0

ENV GOLANG_VERSION 1.21.1

# Install Dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        && rm -rf /var/lib/apt/lists/*

# Download and Extract go binaries
RUN curl -o go.tar.gz https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && set -eux \
    && tar -C /usr/local -zxvf go.tar.gz

# Download source and build exporter
WORKDIR /redis_exporter
RUN git clone https://github.com/oliver006/redis_exporter --branch=v${EXPORTER_VERSION} /redis_exporter \
    && export PATH=$PATH:/usr/local/go/bin \
    && go build \
    && chmod +x redis_exporter

ENTRYPOINT [ "/redis_exporter/redis_exporter" ]
