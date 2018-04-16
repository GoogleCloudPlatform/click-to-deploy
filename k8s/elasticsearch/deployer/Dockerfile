ARG MARKETPLACE_REGISTRY
FROM ${MARKETPLACE_REGISTRY}/deployer_kubectl_base

ARG REGISTRY
ARG TAG
ENV IMAGE_ELASTICSEARCH "$REGISTRY:$TAG"

ADD manifest/* /data/manifest/

RUN mkdir -p /etc/configs \
    && echo -n "default" > /etc/configs/key0 \
    && echo -n "default" > /etc/configs/key2 \
