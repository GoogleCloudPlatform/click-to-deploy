ARG MARKETPLACE_TOOLS_TAG
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild:$MARKETPLACE_TOOLS_TAG

# Since we use "-x <subchart template>", we need a more recent version of Helm
# than the one currently provided by Marketplace Tools 0.7.5
ARG HELM_VERSION=2.12.1

RUN mkdir -p /bin/helm-downloaded \
    && wget -q -O /bin/helm-downloaded/helm.tar.gz \
        https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz \
    && tar -zxvf /bin/helm-downloaded/helm.tar.gz -C /bin/helm-downloaded \
    && mv /bin/helm-downloaded/linux-amd64/helm /bin/ \
    && rm -rf /bin/helm-downloaded

COPY scripts/agones-installer.sh /bin/

RUN chmod a+x /bin/agones-installer.sh
