FROM marketplace.gcr.io/google/debian10

ENV HYDRA_VERSION 2.0.3
ENV HYDRA_SHA256 e24bec23bfd75b634fa357e2a412eb7bd01a4cdf032b141da95e5401888f6b3c
ENV C2D_RELEASE 2.0.3

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
