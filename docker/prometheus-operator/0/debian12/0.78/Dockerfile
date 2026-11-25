# Clone git repo
ARG BASE_REGISTRY="docker.io"
FROM docker.io/alpine/git as git

ENV PROMETHEUS_OPERATOR_VERSION=v0.78.2

RUN git clone https://github.com/prometheus-operator/prometheus-operator.git /src/prometheus-operator/ \
    && cd /src/prometheus-operator/ \
    && git checkout $PROMETHEUS_OPERATOR_VERSION

FROM docker.io/library/golang:1.26-bookworm as builder

COPY --from=git /src/prometheus-operator /go/src/github.com/prometheus-operator/prometheus-operator

WORKDIR /go/src/github.com/prometheus-operator/prometheus-operator

ENV GO111MODULE=on

RUN set -x && \
    apt-get update && apt-get install -qq -y openssl

RUN git config --global http.sslverify false \
    && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s \
    -X github.com/prometheus/common/version.Version=0.78.2 \
    -X github.com/prometheus/common/version.Branch=0.78.2 \
    -X github.com/prometheus/common/version.BuildUser=C2D \
    -X github.com/prometheus/common/version.BuildDate=$(date '+%Y-%m-%d')" \
    -o operator cmd/operator/main.go

# Download licenses
RUN go install github.com/google/go-licenses@latest \
    && go mod download \
    && go-licenses report github.com/prometheus-operator/prometheus-operator/cmd/operator/ > all-licenses

# Result Image
FROM marketplace.gcr.io/google/debian12@sha256:5bf5e3d1f13582b7ccc08efdbb6b26ba15f308945bd7ba1c8f5de34bce96a199

# Patch critical CVEs in base OS layer
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && apt-get install -y --only-upgrade \
        libpcre2-8-0 \
        perl \
        perl-base \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE=0.78.2

# Binaries
COPY --from=builder /go/src/github.com/prometheus-operator/prometheus-operator/operator /bin

# All Licenses
COPY --from=builder /go/src/github.com/prometheus-operator/prometheus-operator/all-licenses /usr/share/prometheus-operator/LICENSE

# User 'nobody' has uid `65534'
USER 65534

ENTRYPOINT ["/bin/operator"]
