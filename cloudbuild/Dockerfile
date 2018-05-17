FROM gcr.io/cloud-builders/docker

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    docker \
    gettext \
    jq \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    python-yaml \
    make \
    uuid-runtime \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pyjwt
RUN pip install cryptography

RUN wget -q -O /usr/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl \
    && chmod 755 /usr/bin/kubectl

RUN wget -q -O /usr/bin/google-cloud-sdk-199.0.0-linux-x86_64.tar.gz \
        https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-199.0.0-linux-x86_64.tar.gz \
    && tar xfC /usr/bin/google-cloud-sdk-199.0.0-linux-x86_64.tar.gz /usr/bin \
    && ln -s /usr/bin/google-cloud-sdk/bin/gcloud /usr/bin/gcloud \
    && chmod 755 /usr/bin/google-cloud-sdk/bin/gcloud
