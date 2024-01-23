FROM marketplace.gcr.io/google/debian12

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
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*