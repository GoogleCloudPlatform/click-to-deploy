ARG MARKETPLACE_TOOLS_TAG

FROM marketplace.gcr.io/google/c2d-debian11 AS build

ARG CHART_NAME

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/$CHART_NAME /tmp/chart
RUN cd /tmp && tar -czvf /tmp/$CHART_NAME.tar.gz chart

ADD apptest/deployer/$CHART_NAME /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/$CHART_NAME.tar.gz chart/

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

RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsutils netcat \
    && rm -rf /var/lib/apt/lists/*

ARG CHART_NAME

RUN sed '/^kubectl apply/ikubectl apply -f /data/extracted/knative/chart/templates/crds/\n\
    kubectl wait --for=condition=Established --timeout=15s crd envoyfilters.networking.istio.io\n\
    kubectl wait --for=condition=Established --timeout=15s crd gateways.networking.istio.io\n\
    kubectl wait --for=condition=Established --timeout=15s crd images.caching.internal.knative.dev' -i /bin/deploy.sh /bin/deploy_with_tests.sh

COPY --from=build /tmp/$CHART_NAME.tar.gz /data/chart/
COPY --from=build /tmp/test/$CHART_NAME.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800
