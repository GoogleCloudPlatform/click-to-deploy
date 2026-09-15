FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV DEBIAN_VERSION 12.4.0
ENV C2D_RELEASE 12.4.0

ENV DEV_APT_DEPS="\
     openssl \
     ca-certificates \
     libtasn1-6 \
     libksba8 \
     libaprutil1 \
     git \
     curl"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${DEV_APT_DEPS} \
    && apt-get install -y --only-upgrade perl zlib1g \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*