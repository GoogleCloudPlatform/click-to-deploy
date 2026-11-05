FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

# This is the release of Consul to pull in.
ENV CONSUL_VERSION 1.19.2
ENV CONSUL_GPG C874011F0AB405110D02105534365D9472D7468F

ENV C2D_RELEASE 1.19.2

# This is the location of the releases.
ENV HASHICORP_RELEASES https://releases.hashicorp.com

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN groupadd -r consul && useradd -r -g consul consul

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gnupg \
    dirmngr \
    && rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.19
ENV GOSU_GPG B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        git \
    ; \
    \
    # Install a secure Go version
    wget -qO- https://go.dev/dl/go1.26.10.linux-amd64.tar.gz | tar -C /usr/local -xzf -; \
    export PATH=$PATH:/usr/local/go/bin; \
    \
    # Compile gosu
    git clone --depth 1 -b "$GOSU_VERSION" https://github.com/tianon/gosu.git /usr/local/src/gosu; \
    cd /usr/local/src/gosu; \
    go build -ldflags '-w -s' -o /usr/local/bin/gosu; \
    \
    # Test gosu runs and clean up build dependencies
    /usr/local/bin/gosu nobody true; \
    rm -rf /usr/local/src/gosu /root/go /root/.cache; \
    rm -rf /var/lib/apt/lists/*

# Set up certificates, base tools, and Consul.
RUN set -eux && \
    buildDependencies=' \
      unzip \
      curl \
      dumb-init \
      libcap-dev \
      openssl \
      iproute2 \
      jq \
    ' && \
    apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
      && apt-get install -qq -y $buildDependencies \
      && apt-get install -y --only-upgrade \
          libpcre2-8-0 \
          perl \
          perl-base \
          zlib1g \
      && rm -rf /var/lib/apt/lists/*

RUN set -eux && \
    export PATH=$PATH:/usr/local/go/bin && \
    git clone --depth 1 --branch "v${CONSUL_VERSION}" https://github.com/hashicorp/consul.git /tmp/build && \
    cd /tmp/build && \
    (grep -q "ExitIdle" agent/grpc-internal/balancer/balancer.go || echo "func (b *balancer) ExitIdle() {}" >> agent/grpc-internal/balancer/balancer.go) && \
    go mod edit \
      -replace="github.com/envoyproxy/go-control-plane=github.com/envoyproxy/go-control-plane@v0.12.0" \
      -replace="go.opentelemetry.io/otel/sdk/metric=go.opentelemetry.io/otel/sdk/metric@v0.39.0" \
      -replace="go.opentelemetry.io/otel/sdk=go.opentelemetry.io/otel/sdk@v1.24.0" \
      -replace="go.opentelemetry.io/otel=go.opentelemetry.io/otel@v1.24.0" \
      -replace="go.opentelemetry.io/otel/trace=go.opentelemetry.io/otel/trace@v1.24.0" \
      -replace="go.opentelemetry.io/otel/metric=go.opentelemetry.io/otel/metric@v1.24.0" \
      -require="google.golang.org/api@v0.195.0" \
      -require="golang.org/x/crypto@v0.52.0" \
      -require="google.golang.org/grpc@v1.79.3" && \
    go mod tidy && \
    CGO_ENABLED=0 go build -trimpath -ldflags "-w -s" -o /bin/consul . && \
    cd /tmp && \
    rm -rf /tmp/build /usr/local/go /root/go /root/.cache && \
    # tiny smoke test to ensure the binary we built runs right version
    test ${C2D_RELEASE} = $(consul version | awk '/Consul/ { print $2 }' | grep -o -E '([0-9]+\.)([0-9]+\.)([0-9]+)'$) \
         || { echo "Version check failed"; exit 1; }

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul

# set up nsswitch.conf for Go's "netgo" implementation which is used by Consul,
# otherwise DNS supercedes the container's hosts file, which we don't want.
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

# Expose the consul data directory as a volume since there's mutable state in there.
VOLUME /consul/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8500 8600 8600/udp

# Copy Mozilla Public License
RUN mkdir -p /usr/share/doc/consul
COPY LICENSE /usr/share/doc/consul/

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-dev", "-client", "0.0.0.0"]
