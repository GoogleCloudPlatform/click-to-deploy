# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.





FROM marketplace.gcr.io/google/debian12 as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install curl ca-certificates

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
		&& chmod +x /download-licenses.sh \
		&& chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses \
		&& /download-ref-repos.sh /source_code.txt /usr/src

# Stage: Server and Workflow Controller: Builder
FROM golang:1.21 as builder

ARG ARGO_VERSION="3.5.10"
ENV ARGO_VERSION "${ARGO_VERSION}"

RUN apt-get update && apt-get --no-install-recommends install -y \
    git \
    make \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    wget \
    gcc && \
    apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

WORKDIR /go/src/github.com/argoproj
RUN git clone https://github.com/argoproj/argo-workflows.git --branch "v${ARGO_VERSION}"
WORKDIR /go/src/github.com/argoproj/argo-workflows
RUN go mod download


# Stage: Server: UI
FROM node:20 as argo-ui

COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/package.json ui/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/yarn.lock ui/

RUN JOBS=max yarn --cwd ui install --network-timeout 1000000

COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/ ui/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/api/ api/

RUN NODE_OPTIONS="--max-old-space-size=2048" JOBS=max yarn --cwd ui build


# Stage: Workflow Controller: Build
FROM builder as workflow-controller-build

# Tell git to forget about all of the files that were not included because of .dockerignore in order to ensure that
# the git state is "clean" even though said .dockerignore files are not present
RUN cat .dockerignore >> .gitignore
RUN git status --porcelain | cut -c4- | xargs git update-index --skip-worktree

RUN target=/root/.cache/go-build make dist/workflow-controller


# Stage: ArgoCLI
FROM builder as argocli-build

RUN mkdir -p ui/dist
COPY --from=argo-ui ui/dist/app ui/dist/app
# stop make from trying to re-build this without yarn installed
RUN touch ui/dist/node_modules.marker
RUN touch ui/dist/app/index.html

# Tell git to forget about all of the files that were not included because of .dockerignore in order to ensure that
# the git state is "clean" even though said .dockerignore files are not present
RUN cat .dockerignore >> .gitignore
RUN git status --porcelain | cut -c4- | xargs git update-index --skip-worktree

RUN target=/root/.cache/go-build make dist/argo


# Stage: Final Image
FROM marketplace.gcr.io/google/debian12

COPY --from=ospo /usr/src /usr/src

ENV C2D_RELEASE "3.5.10"
USER 8737

# Controller artifacts
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/hack/ssh_known_hosts /etc/ssh/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/hack/nsswitch.conf /etc/
COPY --chown=8737 --from=workflow-controller-build /go/src/github.com/argoproj/argo-workflows/dist/workflow-controller /bin/

# CLI artifacts
COPY --from=argocli-build /go/src/github.com/argoproj/argo-workflows/dist/argo /bin/

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
