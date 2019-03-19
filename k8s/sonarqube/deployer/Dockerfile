ARG MARKETPLACE_TOOLS_TAG
FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/sonarqube /tmp/chart
RUN cd /tmp && tar -czvf /tmp/sonarqube.tar.gz chart

ADD apptest/deployer/sonarqube /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/sonarqube.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ENV WAIT_FOR_READY_TIMEOUT 600
ENV TESTER_TIMEOUT 600

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG
COPY --from=build /tmp/sonarqube.tar.gz /data/chart/
COPY --from=build /tmp/test/sonarqube.tar.gz /data-test/chart/
COPY apptest/deployer/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ADD deployer/deploy_with_tests.sh /bin/deploy_with_tests.sh
ADD deployer/deploy.sh /bin/deploy.sh
