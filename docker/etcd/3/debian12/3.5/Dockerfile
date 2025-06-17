# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12 as builder

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y wget git tar gzip build-essential

# Install Go
ARG GO_VERSION=1.22.0
RUN wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

# Configure environment variables for Go
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/go"
ENV PATH="$GOPATH/bin:$PATH"

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin"

# Install govendor
RUN go install github.com/kardianos/govendor@latest

# Configure environment variables for etcd
ARG ETCD_VERSION=3.5.21
ARG ETCD_SHA256=
