FROM gcr.io/google-marketplace-tools/k8s/deployer_envsubst

ADD manifest/* /data/manifest/
ADD schema.yaml /data/

# Provide registry prefix and tag for default values for images.
# TODO(#12): Remove this.
ARG REGISTRY
ARG TAG
RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /data/schema.yaml.new \
    && mv /data/schema.yaml.new /data/schema.yaml
