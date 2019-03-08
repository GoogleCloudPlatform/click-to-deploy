ARG MARKETPLACE_TOOLS_TAG
FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/influxdb /tmp/chart
RUN cd /tmp && tar -czvf /tmp/influxdb.tar.gz chart

ADD apptest/deployer/influxdb /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/influxdb.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml


FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG
COPY --from=build /tmp/influxdb.tar.gz /data/chart/
COPY --from=build /tmp/test/influxdb.tar.gz /data-test/chart/
COPY apptest/deployer/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/
