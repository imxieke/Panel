#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-09-08 22:52:51
 # @LastEditTime: 2024-04-27 12:18:02
 # @LastEditors: Cloudflying
# @Description: Compile PHP 8.2
###

MIRRORS="https://mirrors.xie.ke/pkgs/php/"
PHP_VER="8.2.18"
URL=${MIRRORS}"/php-${PHP_VER}.tar.gz"
DOCKENV_PREFIX="/usr/local/dockenv"
PREFIX_PHP=${DOCKENV_PREFIX}/php/82

mkdir -p /tmp/.build && cd /tmp/.build || exit 1

if [[ ! -f "/tmp/.build/php-${PHP_VER}.tar.gz" ]]; then
  echo "Fetch ${PHP_VER} Source Code"
  wget -c ${URL} -O /tmp/.build/php-${PHP_VER}.tar.gz
fi

if [[ ! -d "/tmp/.build/php-${PHP_VER}" ]]; then
  tar -xvf /tmp/.build/php-${PHP_VER}.tar.gz -C /tmp/.build >/dev/null 2>&1
fi

cd /tmp/.build/php-"${PHP_VER}" || exit 1


./configure \
  --prefix=${PREFIX_PHP} \
  --with-config-file-path="${PREFIX_PHP}/etc" \
  --with-config-file-scan-dir="${PREFIX_PHP}/conf.d" \
  --disable-cgi \
  --disable-phpdbg \
  --enable-bcmath \
  --enable-calendar \
  --enable-dba \
  --enable-exif \
  --enable-fpm \
  --enable-ftp \
  --enable-gd \
  --enable-intl \
  --enable-mbstring \
  --enable-mysqlnd \
  --enable-pcntl \
  --enable-shmop \
  --enable-soap \
  --enable-sockets \
  --enable-sysvmsg \
  --enable-sysvsem \
  --enable-sysvshm \
  --with-avif \
  --with-bz2 \
  --with-curl \
  --with-enchant \
  --with-expat \
  --with-external-gd \
  --with-external-libcrypt \
  --with-external-pcre \
  --with-ffi \
  --with-freetype \
  --with-gettext \
  --with-gmp \
  --with-imap \
  --with-imap-ssl \
  --with-jpeg \
  --with-kerberos \
  --with-ldap \
  --with-mhash \
  --with-mysqli \
  --with-openssl \
  --with-password-argon2 \
  --with-pdo-dblib \
  --with-pdo-mysql \
  --with-pdo-pgsql \
  --with-pdo-sqlite=/usr \
  --with-pgsql \
  --with-pic \
  --with-pspell \
  --with-readline \
  --with-snmp \
  --with-sodium \
  --with-sqlite3=/usr \
  --with-iconv=/usr \
  --with-tidy \
  --with-unixODBC \
  --with-webp \
  --with-xpm \
  --with-xsl \
  --with-zip \
  --with-zlib \
  --with-fpm-user=www \
  --with-fpm-group=www

make -j "$(nproc)"
make install

mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
cp php.ini* ${PREFIX_PHP}/etc/
cp php.ini-development ${PREFIX_PHP}/etc/php.ini
