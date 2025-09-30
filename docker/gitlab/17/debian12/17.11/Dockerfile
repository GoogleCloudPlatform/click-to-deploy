FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

ENV GITLAB_VERSION 17.11.4
ENV DOWNLOAD_URL "https://packages.gitlab.com/gitlab/gitlab-ee/packages/debian/bullseye/gitlab-ee_17.11.4-ee.0_amd64.deb/download.deb"

ENV C2D_RELEASE=17.11.4

SHELL ["/bin/sh", "-c"]

# Default to supporting utf-8
ENV LANG C.UTF-8

# Install required packages
RUN apt-get update -q \
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
