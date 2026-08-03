FROM  marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0 as build
  
  ENV APP_VERSION=1.17.4
  
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
  
  # build binaries using cert-manager's native toolchain
  RUN make vendor-go \
   && make server-binaries
  
  RUN /src/cert-manager/_bin/tools/go install github.com/cert-manager/cmctl/v2@latest
  
  # Result Image
  FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0
  
  RUN apt-get update \
      && apt-get install \
          curl -y --no-install-recommends \
      # Patch critical CVEs in base OS layer
      && apt-get install -y --only-upgrade perl zlib1g \
      && rm -rf /var/lib/apt/lists/*
  
  WORKDIR /app
  
  ENV C2D_RELEASE=1.17.4
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