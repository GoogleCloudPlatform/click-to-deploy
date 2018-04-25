ARG MARKETPLACE_REGISTRY
FROM ${MARKETPLACE_REGISTRY}/deployer_kubectl_base

# Override default values for images.
# TODO(#12): Remove this.
ARG REGISTRY
ARG TAG
RUN mkdir -p /data/values \
    && echo -n "$REGISTRY:$TAG" > /data/values/IMAGE_WORDPRESS \
    && echo -n "$REGISTRY/init:$TAG" > /data/values/IMAGE_WORDPRESS \
    && echo -n "$REGISTRY/init:$TAG" > /data/values/IMAGE_INIT \
    && echo -n "$REGISTRY/mysql:$TAG" > /data/values/IMAGE_MYSQL \
    && echo -n "$REGISTRY/ubbagent:$TAG" > /data/values/IMAGE_UBBAGENT

ADD manifest/* /data/manifest/
ADD schema.yaml /data/
