# Server and Workflow Controller: Builder

FROM golang:1.18 as builder

ARG ARGO_VERSION="3.4.1"
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

# Server: UI
FROM node:16 as argo-ui

COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/package.json ui/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/yarn.lock ui/

RUN JOBS=max yarn --cwd ui install --network-timeout 1000000

COPY --from=builder /go/src/github.com/argoproj/argo-workflows/ui/ ui/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/api/ api/

RUN NODE_OPTIONS="--max-old-space-size=2048" JOBS=max yarn --cwd ui build

# Workflow Controller: Build
FROM builder as workflow-controller-build

# Tell git to forget about all of the files that were not included because of .dockerignore in order to ensure that
# the git state is "clean" even though said .dockerignore files are not present
RUN cat .dockerignore >> .gitignore
RUN git status --porcelain | cut -c4- | xargs git update-index --skip-worktree

RUN target=/root/.cache/go-build make dist/workflow-controller

# ArgoCLI
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

# Final

FROM marketplace.gcr.io/google/debian11

# USER 8737

# Controller artifacts
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/hack/ssh_known_hosts /etc/ssh/
COPY --from=builder /go/src/github.com/argoproj/argo-workflows/hack/nsswitch.conf /etc/
COPY --chown=8737 --from=workflow-controller-build /go/src/github.com/argoproj/argo-workflows/dist/workflow-controller /bin/

# CLI artifacts
COPY --from=argocli-build /go/src/github.com/argoproj/argo-workflows/dist/argo /bin/

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
