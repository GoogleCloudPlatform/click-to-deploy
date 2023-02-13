FROM marketplace.gcr.io/google/debian11

ENV DEV_APT_DEPS="\
     openssl \
     libtasn1-6 \
     libksba8 \
     git \
     curl"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${DEV_APT_DEPS} \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE 11

