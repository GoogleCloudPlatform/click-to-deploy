FROM  marketplace.gcr.io/google/debian11 as build

ENV APP_VERSION=1.11.0

RUN apt-get update \
    && apt-get install make git jq curl docker.io -y --no-install-recommends 

WORKDIR /src/cert-manager/

RUN git clone --branch v${APP_VERSION} \
    https://github.com/cert-manager/cert-manager.git /src/cert-manager/

#build binaries
RUN make vendor-go \
 && make server-binaries \
 && make cmctl-linux

# Result Image
FROM marketplace.gcr.io/google/debian11

WORKDIR /app

# Update openssl and libtasn
RUN apt-get update \
    && apt-get install --no-install-recommends -yqq openssl libtasn1-6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE=1.11.0
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Non root
RUN useradd -r -u 1000 cert-manager

# License and Notices
COPY --from=build /src/cert-manager/LICENSE /usr/share/cert-manager/LICENSE
COPY --from=build /src/cert-manager/LICENSES /usr/share/cert-manager/NOTICES

# App files
COPY --from=build /src/cert-manager/_bin/server/controller-linux-amd64 /app/controller
COPY --from=build /src/cert-manager/_bin/server/cainjector-linux-amd64 /app/cainjector
COPY --from=build /src/cert-manager/_bin/server/webhook-linux-amd64 /app/webhook
COPY --from=build /src/cert-manager/_bin/server/acmesolver-linux-amd64 /app/acmeresolver
COPY --from=build /src/cert-manager/_bin/cmctl/cmctl-linux-amd64 /app/cmctl

USER cert-manager