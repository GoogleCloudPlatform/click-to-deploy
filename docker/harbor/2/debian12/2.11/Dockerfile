FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7

# Patch critical CVEs in base OS layer
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --only-upgrade \
        libpcre2-8-0 \
        perl \
        perl-base \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE 2.11.2
