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



FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/wordpress /tmp/chart
RUN cd /tmp && tar -czvf /tmp/wordpress.tar.gz chart

ADD apptest/deployer/wordpress /tmp/test/chart
RUN cd /tmp/test \
&& tar -czvf /tmp/test/wordpress.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml



ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ARG MARKETPLACE_TOOLS_TAG

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG
COPY --from=build /tmp/wordpress.tar.gz /data/chart/
COPY --from=build /tmp/test/wordpress.tar.gz /data-test/chart/
COPY apptest/deployer/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800
