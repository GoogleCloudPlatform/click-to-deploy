# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12 as builder

# Install basic build tools and wget
RUN apt-get update && \
    apt-get install -y wget tar gzip

# Install Go
ARG GO_VERSION=
RUN wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

ENV PATH="/usr/local/go/bin:$PATH"

# Set etcd version
ARG ETCD_VERSION=3.5.22
ARG ETCD_SHA256=