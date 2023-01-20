FROM marketplace.gcr.io/google/debian11

ARG FALCO_VERSION=0.33.1
ARG VERSION_BUCKET=deb
ENV VERSION_BUCKET=${VERSION_BUCKET}

ENV FALCO_VERSION ${FALCO_VERSION}
ENV C2D_RELEASE 0.33.1
ENV HOST_ROOT /host
ENV HOME /root

RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	bash-completion \
	bc \
	bison \
	clang-11 \
	ca-certificates \
	curl \
	dkms \
	flex \
	gnupg2 \
	gcc \
	jq \
	libc6-dev \
	libelf-dev \
	libssl-dev \
	llvm-11 \
	netcat \
	xz-utils \
	openssl \
  libtasn1-6 \
	&& rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/clang-11 /usr/bin/clang \
	&& ln -s /usr/bin/llc-11 /usr/bin/llc

RUN curl -s https://falco.org/repo/falcosecurity-packages.asc | apt-key add - \
	&& echo "deb https://download.falco.org/packages/${VERSION_BUCKET} stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list \
	&& apt-get update -y \
	&& if [ "$FALCO_VERSION" = "latest" ]; then apt-get install -y --no-install-recommends falco; else apt-get install -y --no-install-recommends falco=${FALCO_VERSION}; fi \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && curl "https://raw.githubusercontent.com/falcosecurity/falco/${FALCO_VERSION}/COPYING" -o /usr/share/falco/LICENSE

# Change the falco config within the container to enable ISO 8601
# output.
RUN sed -e 's/time_format_iso_8601: false/time_format_iso_8601: true/' < /etc/falco/falco.yaml > /etc/falco/falco.yaml.new \
	&& mv /etc/falco/falco.yaml.new /etc/falco/falco.yaml

# Some base images have an empty /lib/modules by default
# If it's not empty, docker build will fail instead of
# silently overwriting the existing directory
RUN rm -df /lib/modules \
	&& ln -s $HOST_ROOT/lib/modules /lib/modules

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/falco"]
