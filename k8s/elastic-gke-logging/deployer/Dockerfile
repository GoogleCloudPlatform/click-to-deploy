ARG MARKETPLACE_TOOLS_TAG
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst:$MARKETPLACE_TOOLS_TAG

COPY manifest/* /data/manifest/
COPY schema.yaml /data/
COPY apptest/deployer /data-test/

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG

ENV WAIT_FOR_READY_TIMEOUT 1200
ENV TESTER_TIMEOUT 1200

RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /data/schema.yaml.new \
    && mv /data/schema.yaml.new /data/schema.yaml
