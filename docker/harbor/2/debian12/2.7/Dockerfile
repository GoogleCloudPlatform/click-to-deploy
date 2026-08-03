FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

# Patch critical CVEs in base OS layer
RUN apt-get update && apt-get install -y --only-upgrade \
    perl \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV C2D_RELEASE 2.7.4
