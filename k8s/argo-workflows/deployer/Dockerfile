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
ADD chart/$CHART_NAME/values.yaml /tmp/values.yaml

# Provide registry prefix and tag for default values for images.
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
    && apt-get -y install \
      git jq libghc-yaml-dev

ARG CHART_NAME

COPY --from=build /tmp/values.yaml /data/
WORKDIR /crd

RUN argo_version="$(yaml2json /data/values.yaml | jq -r '.argo_workflows.version')" \
    && git clone https://github.com/argoproj/argo-workflows.git --branch "${argo_version}" \
    && rm -f argo-workflows/manifests/base/crds/minimal/kustomization.yaml \
    && rm -f argo-workflows/manifests/base/crds/minimal/README.md \
    && argoevents_version="$(cat argo-workflows/go.mod | grep "argo-events" | grep -P -o "v(\d+)\.(\d+).(\d)$")" \
    && git clone https://github.com/argoproj/argo-events.git --branch "${argoevents_version}" \
    && rm -f argo-events/manifests/base/crds/kustomization.yaml

RUN sed '/^kubectl apply/ikubectl apply -f /crd/argo-workflows/manifests/base/crds/minimal/\n\
    kubectl apply -f /crd/argo-events/manifests/base/crds/\n\
    kubectl wait --for=condition=Established --timeout=15s crd workflows.argoproj.io\n\
    kubectl wait --for=condition=Established --timeout=15s crd cronworkflows.argoproj.io\n\
    kubectl wait --for=condition=Established --timeout=15s crd sensors.argoproj.io' -i /bin/deploy.sh /bin/deploy_with_tests.sh

COPY --from=build /tmp/$CHART_NAME.tar.gz /data/chart/
COPY --from=build /tmp/test/$CHART_NAME.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800
