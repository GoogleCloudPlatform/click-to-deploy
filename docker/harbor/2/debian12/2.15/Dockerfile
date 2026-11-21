FROM marketplace.gcr.io/google/debian12@sha256:a623af62efaf2d260a05aae6869fd48ef8abedb957c6afd10028ac1a2993ba53

# Patch critical CVEs in base OS layer
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --only-upgrade \
        libpcre2-8-0 \
        perl \
        perl-base \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE 2.15.5
