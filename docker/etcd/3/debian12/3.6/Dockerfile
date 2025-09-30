# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861 as builder

# Install basic build tools and wget
RUN apt-get update && \
    apt-get install -y wget tar gzip

# Install Go
ARG GO_VERSION=1.22.0
RUN wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

ENV PATH="/usr/local/go/bin:$PATH"

# Set etcd version
ARG ETCD_VERSION=3.6.0
ARG ETCD_SHA256=