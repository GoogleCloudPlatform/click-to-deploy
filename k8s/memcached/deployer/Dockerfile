ARG MARKETPLACE_TOOLS_TAG
FROM marketplace.gcr.io/google/c2d-debian11 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/memcached /tmp/chart
RUN cd /tmp && tar -czvf /tmp/memcached.tar.gz chart

ADD apptest/deployer/memcached /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/memcached.tar.gz chart/

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

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG
COPY --from=build /tmp/memcached.tar.gz /data/chart/
COPY --from=build /tmp/test/memcached.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/
