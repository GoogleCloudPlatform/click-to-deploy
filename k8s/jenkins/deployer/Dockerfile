ARG MARKETPLACE_TOOLS_TAG
FROM marketplace.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/jenkins /tmp/chart
RUN cd /tmp && tar -czvf /tmp/jenkins.tar.gz chart

ADD apptest/deployer/jenkins /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/jenkins.tar.gz chart/

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
COPY --from=build /tmp/jenkins.tar.gz /data/chart/
COPY --from=build /tmp/test/jenkins.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800

RUN mv -f /bin/deploy.sh /bin/deploy-original.sh \
    && cp /bin/clean_iam_resources.sh /bin/clean_iam_resources-original.sh \
    && echo '#!/bin/bash\nexit' > /bin/clean_iam_resources.sh
ADD deployer/entrypoint.sh /bin/deploy.sh
