FROM marketplace.gcr.io/google/debian11

ENV HYDRA_VERSION 1.11.8
ENV HYDRA_SHA256 98355a10277858fd9d71869aba05652a986fb3c056b731a9d9313f2166ab11c3
ENV C2D_RELEASE 1.11.8

RUN addgroup --system ory; \
    adduser --system --group --disabled-password  --home /home/ory --shell /usr/sbin/nologin ory; \
    chown -R ory:ory /home/ory

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget curl vim lynx \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/hydra.tar.gz https://github.com/ory/hydra/releases/download/v${HYDRA_VERSION}/hydra_${HYDRA_VERSION}-linux_64bit.tar.gz \
    && echo "${HYDRA_SHA256} /opt/hydra.tar.gz" | sha256sum -c \
    && tar xzf /opt/hydra.tar.gz -C /opt/

USER ory

ENTRYPOINT ["/opt/hydra"]
CMD ["serve", "all"]
