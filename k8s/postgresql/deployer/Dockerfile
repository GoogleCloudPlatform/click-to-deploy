ARG MARKETPLACE_TOOLS_TAG
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst:$MARKETPLACE_TOOLS_TAG

COPY manifest/* /data/manifest/
COPY schema.yaml /data/
COPY apptest/deployer /data-test/

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /data/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /data/schema.yaml.new \
    && mv /data/schema.yaml.new /data/schema.yaml

RUN mv -f /bin/deploy.sh /bin/deploy-original.sh \
    && mv -f /bin/deploy_with_tests.sh /bin/deploy_with_tests-original.sh \
    && cp /bin/clean_iam_resources.sh /bin/clean_iam_resources-original.sh \
    && echo '#!/bin/bash\nexit' > /bin/clean_iam_resources.sh

ADD deployer/deploy_with_tests.sh /bin/deploy_with_tests.sh
ADD deployer/deploy.sh /bin/deploy.sh
