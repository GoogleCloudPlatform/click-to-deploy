FROM  marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c as build
  
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
  RUN sed -i 's/^VENDORED_GO_VERSION := .*/VENDORED_GO_VERSION := 1.26.10/' make/_shared/tools/00_mod.mk \
   && sed -i 's/^go_linux_amd64_SHA256SUM=.*/go_linux_amd64_SHA256SUM=ccfe7ae822d2c2f41f4fe7c956199967a4dac22d0ee0d2b2bfdb440aab3b20c5/' make/_shared/tools/00_mod.mk \
   && make vendor-go \
   && export GOROOT=/src/cert-manager/_bin/tools/goroot \
   && export PATH="/src/cert-manager/_bin/tools/goroot/bin:${PATH}" \
   && for moddir in . cmd/controller cmd/cainjector cmd/webhook cmd/acmesolver cmd/startupapicheck; do \
        (cd "$moddir" && /src/cert-manager/_bin/tools/go get golang.org/x/crypto@v0.52.0 google.golang.org/grpc@v1.79.3 && /src/cert-manager/_bin/tools/go mod tidy); \
      done \
   && make server-binaries
  
  RUN GOROOT=/src/cert-manager/_bin/tools/goroot PATH="/src/cert-manager/_bin/tools/goroot/bin:${PATH}" GOTOOLCHAIN=local \
      /src/cert-manager/_bin/tools/go install github.com/cert-manager/cmctl/v2@latest
  
  # Result Image
  FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c
  
  RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
      && apt-get install \
          curl -y --no-install-recommends \
      # Patch critical CVEs in base OS layer
      && apt-get install -y --only-upgrade \
          libpcre2-8-0 \
          perl \
          perl-base \
          zlib1g \
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
  		/download-licenses.sh /components.csv /usr/src/licenses && \
  		apt-get purge -y --auto-remove pup && \
  		rm -rf /var/lib/apt/lists/*
  
  USER cert-manager