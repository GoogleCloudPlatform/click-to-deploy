FROM marketplace.gcr.io/google/c2d-debian11

ENV HYDRA_VERSION 2.2.0
ENV HYDRA_SHA256 e53a053a168a8329f12b1cc776477edc8956e4eebc3cf9fa4ad521e66f60892c
ENV C2D_RELEASE 2.2.0

RUN addgroup --system ory; \
    adduser --system --group --disabled-password  --home /home/ory --shell /usr/sbin/nologin ory; \
    chown -R ory:ory /home/ory

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget ca-certificates vim lynx \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/hydra.tar.gz https://github.com/ory/hydra/releases/download/v${HYDRA_VERSION}/hydra_${HYDRA_VERSION}-linux_64bit.tar.gz \
    && echo "${HYDRA_SHA256} /opt/hydra.tar.gz" | sha256sum -c \
    && tar xzf /opt/hydra.tar.gz -C /opt/

USER ory

ENTRYPOINT ["/opt/hydra"]
CMD ["serve", "all"]
