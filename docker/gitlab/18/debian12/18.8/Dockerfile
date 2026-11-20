FROM marketplace.gcr.io/google/debian12 AS nginx-builder

ENV NGINX_VERSION=1.30.7 \
    NGINX_SHA256=2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e \
    NGINX_VTS_VERSION=0.2.7 \
    NGINX_VTS_SHA256=9f3e5fd74f780b33d5de421db96ebb297fe7b0e611832181b2064c03a4faf09c \
    NGX_SECURITY_HEADERS_VERSION=0.0.9 \
    NGX_SECURITY_HEADERS_SHA256=8a65f4f9f5080db63437c4d729fb3b1f676c1e9af1104eb71c8f50bedf0a381a

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      build-essential \
      ca-certificates \
      libpcre2-dev \
      libssl-dev \
      wget \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/nginx-build \
    && cd /tmp/nginx-build \
    && wget -q "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz \
    && echo "${NGINX_SHA256}  nginx.tar.gz" | sha256sum -c - \
    && wget -q "https://gitlab.com/gitlab-org/build/omnibus-mirror/nginx-module-vts/-/archive/v${NGINX_VTS_VERSION}/nginx-module-vts-v${NGINX_VTS_VERSION}.tar.gz" -O vts.tar.gz \
    && echo "${NGINX_VTS_SHA256}  vts.tar.gz" | sha256sum -c - \
    && wget -q "https://gitlab.com/gitlab-org/build/omnibus-mirror/ngx_security_headers/-/archive/${NGX_SECURITY_HEADERS_VERSION}/ngx_security_headers-${NGX_SECURITY_HEADERS_VERSION}.tar.gz" -O sechdr.tar.gz \
    && echo "${NGX_SECURITY_HEADERS_SHA256}  sechdr.tar.gz" | sha256sum -c - \
    && tar -xzf nginx.tar.gz \
    && tar -xzf vts.tar.gz \
    && tar -xzf sechdr.tar.gz \
    && cd "nginx-${NGINX_VERSION}" \
    && ./configure \
      --prefix=/opt/gitlab/embedded \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-http_gzip_static_module \
      --with-http_v2_module \
      --with-http_realip_module \
      --with-http_sub_module \
      --with-ipv6 \
      --with-debug \
      --add-module="/tmp/nginx-build/nginx-module-vts-v${NGINX_VTS_VERSION}" \
      --add-module="/tmp/nginx-build/ngx_security_headers-${NGX_SECURITY_HEADERS_VERSION}" \
    && make -j"$(nproc)" \
    && make install

FROM marketplace.gcr.io/google/debian12

ENV GITLAB_VERSION 18.8.0
ENV NGINX_VERSION 1.30.7
ENV DOWNLOAD_URL "https://packages.gitlab.com/gitlab/gitlab-ee/packages/debian/bullseye/gitlab-ee_18.8.0-ee.0_amd64.deb/download.deb"

ENV C2D_RELEASE=18.8.0

SHELL ["/bin/sh", "-c"]

# Default to supporting utf-8
ENV LANG C.UTF-8

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      ca-certificates \
      openssh-server \
      wget \
      apt-transport-https \
      vim \
      tzdata \
      nano \
      less \
      openssl \
      perl \
      jq \
    && rm -rf /var/lib/apt/lists/* \
    && sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Copy assets
COPY assets/ /assets/
RUN /assets/setup

# Replace Omnibus embedded NGINX with patched 1.30.7 (remediates Nov 2026 NGINX CVEs)
COPY --from=nginx-builder /opt/gitlab/embedded/sbin/nginx /opt/gitlab/embedded/sbin/nginx
RUN /opt/gitlab/embedded/sbin/nginx -V 2>&1 | grep -q "nginx/${NGINX_VERSION}" \
    && ! ldd /opt/gitlab/embedded/sbin/nginx | grep -q "not found" \
    && if [ -f /opt/gitlab/version-manifest.txt ]; then \
         sed -i -E "s/^(nginx[[:space:]]+)release-[0-9.]+/\1release-${NGINX_VERSION}/; s/^(nginx-module-vts[[:space:]]+)v[0-9.]+/\1v0.2.7/" /opt/gitlab/version-manifest.txt; \
       fi \
    && if [ -f /opt/gitlab/version-manifest.json ]; then \
         jq --arg nv "${NGINX_VERSION}" \
           '.software.nginx.described_version = ("release-" + $nv) | .software.nginx.display_version = $nv | .software.nginx.locked_version = ("release-" + $nv) | .software["nginx-module-vts"].described_version = "v0.2.7" | .software["nginx-module-vts"].display_version = "v0.2.7" | .software["nginx-module-vts"].locked_version = "v0.2.7"' \
           /opt/gitlab/version-manifest.json > /opt/gitlab/version-manifest.json.tmp \
         && mv /opt/gitlab/version-manifest.json.tmp /opt/gitlab/version-manifest.json; \
       fi

# Allow to access embedded tools
ENV PATH /opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH

# Expose web & ssh
EXPOSE 443 80 22

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

COPY curl-with-retry-localhost.sh /curl-with-retry-localhost.sh
RUN chmod +x /curl-with-retry-localhost.sh

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10
