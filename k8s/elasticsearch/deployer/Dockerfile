ARG MARKETPLACE_REGISTRY
FROM ${MARKETPLACE_REGISTRY}/deployer_kubectl_base

# Override default values for images.
# TODO(#12): Remove this.
ARG REGISTRY
ARG TAG
RUN mkdir -p /data/values \
    && echo -n "$REGISTRY:$TAG" > /data/values/IMAGE_ELASTICSEARCH \
    && echo -n "$REGISTRY/debian9:$TAG" > /data/values/IMAGE_INIT

ADD manifest/* /data/manifest/
ADD schema.yaml /data/
