FROM golang:1.18 as builder

ARG ARGO_VERSION="3.4.1"
ENV ARGO_VERSION "${ARGO_VERSION}"

RUN apt-get update && apt-get --no-install-recommends install -y \
    git \
    make \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    wget \
    gcc && \
    apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

WORKDIR /go/src/github.com/argoproj
RUN git clone https://github.com/argoproj/argo-workflows.git --branch "v${ARGO_VERSION}"

# https://blog.container-solutions.com/faster-builds-in-docker-with-go-1-11
WORKDIR /go/src/github.com/argoproj/argo-workflows
# COPY go.mod .
# COPY go.sum .
RUN go mod download


FROM node:16 as argo-ui

COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/package.json /src
WORKDIR /go/src/github.com/argoproj/argo-workflows

RUN ui/package.json ui/yarn.lock ui/

RUN JOBS=max yarn --cwd ui install --network-timeout 1000000

COPY ui ui
COPY api api

RUN NODE_OPTIONS="--max-old-space-size=2048" JOBS=max yarn --cwd ui build

# FROM marketplace.gcr.io/google/debian11 as builder


# RUN apt install -y git

#
# WORKDIR /argo-workflows



# Build Workflow Controller


# FROM marketplace.gcr.io/google/debian11

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
