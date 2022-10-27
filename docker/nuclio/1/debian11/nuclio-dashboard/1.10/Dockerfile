FROM marketplace.gcr.io/google/debian11 as build

WORKDIR /app

#copy Nuclio sources
ARG NUCLIO_VERSION=1.10.8
ARG NUCLIO_DIST=https://github.com/nuclio/nuclio/archive/refs/tags/${NUCLIO_VERSION}.tar.gz
ADD $NUCLIO_DIST /tmp/nuclio.tar.gz
RUN (tar -xvf /tmp/nuclio.tar.gz -C /app/ && rm /tmp/nuclio.tar.gz && mv /app/nuclio-${NUCLIO_VERSION}/* /app/) || true

#install docker cli
RUN apt-get update && apt-get install ca-certificates golang -y \
    && rm -rf /var/lib/apt/lists/*

#build controller binary
ARG NUCLIO_GO_LINK_FLAGS_INJECT_VERSION
ARG GOOS=linux
ARG GOARCH=amd64
RUN cd /app/cmd/controller/ && GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED=0 go build \
    -a \
    -installsuffix cgo \
    -ldflags="${NUCLIO_GO_LINK_FLAGS_INJECT_VERSION}" \
    -o controller main.go

FROM marketplace.gcr.io/google/debian11

ARG NUCLIO_VERSION
ENV C2D_RELEASE=${NUCLIO_VERSION}

# install apache2-utils for htpasswd
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates apache2-utils \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# copy controller binary from build binary stage
COPY --from=build /app/cmd/controller/controller /usr/local/bin

#copy LICENSE
COPY --from=build /app/LICENSE /usr/share/nuclio/LICENSE

CMD [ "controller" ]
