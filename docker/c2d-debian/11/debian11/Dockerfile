FROM marketplace.gcr.io/google/debian11@sha256:b441186c557eeef29805ee38557fd11b2bb4cf09af655238f3103c49a15ac505

ENV DEBIAN_VERSION 11.5.0
ENV C2D_RELEASE 11.5.0

ENV DEV_APT_DEPS="\
     openssl \
     libtasn1-6 \
     libksba8 \
     libssl1.1 \
     libaprutil1 \
     git \
     curl"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${DEV_APT_DEPS} \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*