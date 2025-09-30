FROM  marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861 as build

ENV APP_VERSION=1.15.5

RUN apt-get update \
    && apt-get install \
        git \
        curl \
        rsync \
        make \
        jq \
        docker.io \
        ca-certificates -y --no-install-recommends

WORKDIR /src/cert-manager/

RUN git clone --branch v${APP_VERSION} \
    https://github.com/cert-manager/cert-manager.git /src/cert-manager/

#build binaries
RUN make vendor-go \
 && make server-binaries

RUN /src/cert-manager/_bin/tools/go install github.com/cert-manager/cmctl/v2@latest

# Result Image
FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

RUN apt-get update \
    && apt-get install \
        curl -y --no-install-recommends

WORKDIR /app

ENV C2D_RELEASE=1.15.5
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
COPY --from=build /root/go/bin/cmctl /app/cmctl
COPY --from=build /src/cert-manager/ /usr/src/cert-manager

# Download Licenses
COPY components.csv /components.csv
COPY download-licenses.sh /download-licenses.sh
RUN mkdir -p /usr/src && \
		/download-licenses.sh /components.csv /usr/src/licenses

USER cert-manager
