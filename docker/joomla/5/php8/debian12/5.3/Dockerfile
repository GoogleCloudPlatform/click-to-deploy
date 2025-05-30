FROM marketplace.gcr.io/google/php8-apache2:8.2

RUN set -ex; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libbz2-dev \
    libpq-dev \
    libldap2-dev \
    libexpat1 \
    libmemcached-dev \
  ; \
  \
  docker-php-ext-configure gd --with-jpeg=/usr; \
  debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
  docker-php-ext-install -j "$(nproc)" \
    bz2 \
    gd \
    ldap \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    zip \
    opcache \
  ; \
# pecl will claim success even if one install fails, so we need to perform each install separately
  pecl install APCu-5.1.21; \
  pecl install memcached-3.2.0; \
  pecl install redis-5.3.7; \
  \
  docker-php-ext-enable \
    apcu \
    memcached \
    redis \
  ; \
  \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    | awk '/=>/ { print $3 }' \
    | sort -u \
    | xargs -r realpath | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -rt apt-mark manual; \
  \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN a2enmod rewrite expires

RUN set -ex ;\
  apt-get update ;\
  apt-get install -y mariadb-client linux-libc-dev \
  && rm -rf /var/lib/apt/lists/*

VOLUME /var/www/html

ENV JOOMLA_VERSION 5.3.0
ENV C2D_RELEASE 5.3.0

# Download package and extract to web volume
RUN set -ex; \
  curl -o joomla.tar.gz -SL https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.gz; \
  mkdir /usr/src/joomla; \
  tar -xf joomla.tar.gz -C /usr/src/joomla; \
  rm joomla.tar.gz; \
  chown -R www-data:www-data /usr/src/joomla

# Copy init scripts
COPY docker-entrypoint.sh /entrypoint.sh
COPY makedb.php /makedb.php

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
