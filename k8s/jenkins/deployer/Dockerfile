ARG MARKETPLACE_TOOLS_TAG
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst:$MARKETPLACE_TOOLS_TAG

COPY manifest/* /data/manifest/
COPY schema.yaml /data/
COPY apptest/deployer /data-test/

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800

RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /data/schema.yaml.new \
    && mv /data/schema.yaml.new /data/schema.yaml

RUN mv -f /bin/deploy.sh /bin/deploy-original.sh \
    && cp /bin/clean_iam_resources.sh /bin/clean_iam_resources-original.sh \
    && echo '#!/bin/bash\nexit' > /bin/clean_iam_resources.sh
ADD deployer/entrypoint.sh /bin/deploy.sh
