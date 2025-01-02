FROM marketplace.gcr.io/google/debian12

ENV GITLAB_VERSION 17.5.1
ENV DOWNLOAD_URL "https://packages.gitlab.com/gitlab/gitlab-ee/packages/debian/bullseye/gitlab-ee_17.5.1-ee.0_amd64.deb/download.deb"

ENV C2D_RELEASE=17.5.1

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

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10
