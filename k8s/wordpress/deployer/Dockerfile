ARG MARKETPLACE_REGISTRY
FROM ${MARKETPLACE_REGISTRY}/deployer_kubectl_base

ADD manifest/* /data/manifest/
ADD schema.yaml /data/

# Override default values for images.
# TODO(#12): Remove this.
ARG REGISTRY
ARG TAG

RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    >> /data/schema.yaml
