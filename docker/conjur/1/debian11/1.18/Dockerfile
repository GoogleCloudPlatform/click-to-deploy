FROM marketplace.gcr.io/google/debian11:latest

SHELL ["/bin/bash", "-c", "-l"]

COPY sample_policy.yaml /opt/conjur-server/
COPY entrypoint.sh run_test.sh /usr/local/bin/

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=80 \
    LOG_DIR=/opt/conjur-server/log \
    TMP_DIR=/opt/conjur-server/tmp \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

ENV CONJUR_APP_VERSION=1.18.1
ENV CONJUR_CLI_VERSION=6.2.6
ENV OPENSSL_FIPS_ENABLED "false"

EXPOSE 80

RUN apt-get update \
    && apt-get install \
    curl \
    libz-dev \
    build-essential \
    git \
    ldap-utils \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    procps \
    libpq-dev \
    -y --no-install-recommends \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/conjur-server

RUN mkdir -p $TMP_DIR \
             $LOG_DIR \
             $SSL_CERT_DIRECTORY/ca \
             $SSL_CERT_DIRECTORY/cert \
             /run/authn-local

RUN curl -L https://github.com/cyberark/conjur/archive/refs/tags/v${CONJUR_APP_VERSION}.tar.gz -o ./conjur.tar.gz \
    && tar -xzf ./conjur.tar.gz \
    && mv ./conjur-*/* ./ \
    && rm -f ./conjur.tar.gz

#install ruby3
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import - \
    && curl -sSL https://get.rvm.io | bash -s stable --ruby \
    && source /usr/local/rvm/scripts/rvm \
    && rvm install 3.0.0 \
    && gem install bundler

RUN bundle --without test development

# removing CA bundle of httpclient gem
RUN find / -name httpclient -type d -exec find {} -name *.pem -type f -delete \;

RUN ln -sf /opt/conjur-server/bin/conjurctl /usr/local/bin/ \
    && echo $CONJUR_APP_VERSION > ./VERSION

#install conjur-cli
RUN gem install conjur-cli -v $CONJUR_CLI_VERSION

ENV RAILS_ENV production

#preserve ruby ENVs
ENV PATH "/usr/local/rvm/gems/ruby-3.0.0/bin:/usr/local/rvm/gems/ruby-3.0.0@global/bin:/usr/local/rvm/rubies/ruby-3.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin"
ENV GEM_HOME "/usr/local/rvm/gems/ruby-3.0.0"

EXPOSE 80

ENV C2D_RELEASE 1.18.1

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["conjurctl", "server"]
