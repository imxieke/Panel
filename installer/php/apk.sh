#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-10-15 18:36:32
# @LastEditTime: 2024-04-27 09:14:13
# @LastEditors: Cloudflying
# @Description: Add PHP Package Via Alpine Package Manager On Docker,
#  			 Multiple versions cannot exist at the same time.
###

php_81() {
  PHP_VER=81
  apk add --no-cache \
    php81-bcmath \
    php81-brotli \
    php81-bz2 \
    php81-calendar \
    php81-common \
    php81-ctype \
    php81-curl \
    php81-dba \
    php81-dev \
    php81-dom \
    php81-embed \
    php81-enchant \
    php81-exif \
    php81-ffi \
    php81-fileinfo \
    php81-fpm \
    php81-ftp \
    php81-gd \
    php81-gettext \
    php81-gmp \
    php81-iconv \
    php81-imap \
    php81-intl \
    php81-ldap \
    php81-mbstring \
    php81-mysqli \
    php81-mysqlnd \
    php81-odbc \
    php81-opcache \
    php81-openssl \
    php81-pcntl \
    php81-pdo \
    php81-pdo_dblib \
    php81-pdo_mysql \
    php81-pdo_odbc \
    php81-pdo_pgsql \
    php81-pdo_sqlite \
    php81-pecl-amqp \
    php81-pecl-apcu \
    php81-pecl-ast \
    php81-pecl-couchbase \
    php81-pecl-event \
    php81-pecl-igbinary \
    php81-pecl-imagick \
    php81-pecl-imagick-dev \
    php81-pecl-lzf \
    php81-pecl-memcache \
    php81-pecl-memcached \
    php81-pecl-mongodb \
    php81-pecl-msgpack \
    php81-pecl-protobuf \
    php81-pecl-psr \
    php81-pecl-rdkafka \
    php81-pecl-redis \
    php81-pecl-smbclient \
    php81-pecl-ssh2 \
    php81-pecl-swoole \
    php81-pecl-swoole-dev \
    php81-pecl-uuid \
    php81-pecl-vips \
    php81-pecl-xdebug \
    php81-pecl-xhprof \
    php81-pecl-xhprof-assets \
    php81-pecl-yaml \
    php81-pecl-zstd \
    php81-pgsql \
    php81-phar \
    php81-phpdbg \
    php81-posix \
    php81-pspell \
    php81-session \
    php81-shmop \
    php81-simplexml \
    php81-snmp \
    php81-soap \
    php81-sockets \
    php81-sodium \
    php81-sqlite3 \
    php81-sysvmsg \
    php81-sysvsem \
    php81-sysvshm \
    php81-tidy \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-xsl \
    php81-zip

  rm -fr /usr/bin/php
  rm -fr /usr/bin/phpize
  rm -fr /usr/bin/phpdbg
  rm -fr /usr/bin/php-config
  mv /usr/bin/php${PHP_VER} /usr/bin/php
  mv /usr/bin/phpdbg${PHP_VER} /usr/bin/phpdbg
  mv /usr/bin/phpize${PHP_VER} /usr/bin/phpize
  mv /usr/sbin/php-fpm${PHP_VER} /usr/sbin/php-fpm
  mv /usr/bin/php-config${PHP_VER} /usr/bin/php-config

  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php${PHP_VER}/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php${PHP_VER}/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php${PHP_VER}/php.ini
  sed -i "s/date.timezone.*/date.timezone = 'Asia\/Shanghai'/" /etc/php${PHP_VER}/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 512M/" /etc/php${PHP_VER}/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 512M/" /etc/php${PHP_VER}/php.ini
  sed -i "s/max_file_uploads =.*/max_file_uploads = 256/g" /etc/php${PHP_VER}/php.ini
  sed -i "s/display_startup_errors =.*/display_startup_errors = On/g" /etc/php${PHP_VER}/php.ini
  sed -i "s/log_errors =.*/log_errors = On/g" /etc/php${PHP_VER}/php.ini
  sed -i 's/default_charset =.*/default_charset = "UTF-8"/g' /etc/php${PHP_VER}/php.ini
  sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /etc/php${PHP_VER}/php.ini
  sed -i "s#^pm.max_children.*#pm.max_children = 32#" /etc/php${PHP_VER}/php-fpm.d/*.conf
  sed -i "s#^listen =.*#listen = 0.0.0.0:9000#" /etc/php${PHP_VER}/php-fpm.d/*.conf

  wget https://github.com/dockenv/dockenv-images/releases/download/ioncube/ioncube_loader_lin_8.1.so -O /usr/lib/php"${PHP_VER}"/modules/ioncube.so
  echo "zend_extension=ioncube.so" >>/etc/php${PHP_VER}/php.ini
  wget https://github.com/dockenv/dockenv-images/releases/download/SourceGuardian/ixed.8.1.lin -O /usr/lib/php"${PHP_VER}"/modules/ixed.so
  echo "[sourceguardian]" >/etc/php${PHP_VER}/conf.d/sourceguardian.ini
  echo "zend_extension=ixed.so" >>/etc/php${PHP_VER}/conf.d/sourceguardian.ini
}

apk add --no-cache --virtual .deps \
  autoconf \
  bison \
  curl \
  dpkg-dev dpkg \
  file \
  g++ \
  gcc \
  libc-dev \
  make \
  pkgconf \
  tar \
  re2c \
  xz \
  argon2-dev \
  coreutils \
  curl-dev \
  gd-dev \
  gmp-dev \
  imap-dev \
  icu-dev \
  gnu-libiconv-dev \
  libsodium-dev \
  libxml2-dev \
  linux-headers \
  oniguruma-dev \
  openssl-dev \
  readline-dev \
  sqlite-dev \
  openldap-dev \
  freetds-dev \
  unixodbc-dev \
  tidyhtml-dev \
  krb5-dev \
  pcre2-dev \
  bzip2-dev \
  libzip-dev \
  libxslt-dev \
  libffi-dev \
  enchant2-dev
