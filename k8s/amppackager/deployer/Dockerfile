ARG MARKETPLACE_TOOLS_TAG
FROM marketplace.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/amppackager /tmp/chart
RUN cd /tmp && tar -czvf /tmp/amppackager.tar.gz chart

ADD apptest/deployer/amppackager /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/amppackager.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
RUN cat /tmp/apptest/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/apptest/schema.yaml.new \
    && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

# For testing only:
# FROM gcr.io/cloud-marketplace-staging/marketplace-k8s-app-tools/k8s/deployer_helm:unreleased-pr396
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG

COPY --from=build /tmp/amppackager.tar.gz /data/chart/
COPY --from=build /tmp/test/amppackager.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 180
