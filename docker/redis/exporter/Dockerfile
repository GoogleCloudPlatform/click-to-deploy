FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7

ENV EXPORTER_VERSION 1.63.0

ENV GOLANG_VERSION 1.26.10

# Install Dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
    && apt-get install -y --only-upgrade \
        libpcre2-8-0 \
        perl \
        perl-base \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Download and Extract go binaries
RUN curl -o go.tar.gz https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && set -eux \
    && tar -C /usr/local -zxvf go.tar.gz

# Download source and build exporter
WORKDIR /redis_exporter
RUN git clone https://github.com/oliver006/redis_exporter --branch=v${EXPORTER_VERSION} /redis_exporter \
    && export PATH=$PATH:/usr/local/go/bin \
    && go get github.com/klauspost/compress@v1.18.7 \
    && go mod tidy \
    && go build \
    && chmod +x redis_exporter \
    && rm -rf /usr/local/go /go.tar.gz /root/.cache /root/go

ENTRYPOINT [ "/redis_exporter/redis_exporter" ]
