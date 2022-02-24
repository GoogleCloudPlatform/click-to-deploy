# Clone git repo
FROM alpine/git:1.0.7 as git

ENV PROMETHEUS_OPERATOR_VERSION=v0.54.0

RUN git clone https://github.com/coreos/prometheus-operator.git /src/prometheus-operator/ \
    && cd /src/prometheus-operator/ \
    && git checkout $PROMETHEUS_OPERATOR_VERSION

FROM golang:1.17 as builder

COPY --from=git /src/prometheus-operator /go/src/github.com/coreos/prometheus-operator

WORKDIR /go/src/github.com/coreos/prometheus-operator

ENV GO111MODULE=on

RUN git config --global http.sslverify false \
    && go get -u github.com/kardianos/govendor \
    && govendor license +vendor > NOTICES \
    && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s \
    -X github.com/coreos/prometheus-operator/pkg/version.Version=0.54.0" \
    -o operator cmd/operator/main.go

# Result Image
FROM gcr.io/google-appengine/debian10:latest

ENV C2D_RELEASE=0.54.0

# Binaries
COPY --from=builder /go/src/github.com/coreos/prometheus-operator/operator /bin

# License and Notices
COPY --from=builder /go/src/github.com/coreos/prometheus-operator/NOTICES /usr/share/prometheus-operator/NOTICES
COPY --from=builder /go/src/github.com/coreos/prometheus-operator/LICENSE /usr/share/prometheus-operator/LICENSE

# User 'nobody' has uid `65534'
USER 65534

ENTRYPOINT ["/bin/operator"]
