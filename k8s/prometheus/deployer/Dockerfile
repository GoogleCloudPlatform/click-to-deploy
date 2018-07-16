FROM gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst:v0.6.2

ADD manifest/* /data/manifest/
ADD schema.yaml /data/

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /data/schema.yaml.new \
    && mv /data/schema.yaml.new /data/schema.yaml
