#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-09-08 22:52:46
# @LastEditTime: 2024-04-27 12:48:36
# @LastEditors: Cloudflying
# @Description:
###

MIRRORS="https://mirrors.xie.ke/pkgs/php/"
PHP_VER="7.4.33"
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

# export CFLAGS="-I/usr/include/enchant-2 -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include ${CFLAGS}"
# export LIBS="-L/usr/lib/x86_64-linux-gnu -lenchant-2 -L${libdir} -lglib-2.0"
includedir="/usr/include"
libdir="/usr/lib/x86_64-linux-gnu"
export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig：/usr/lib/pkgconfig:/usr/share/pkgconfig:${PKG_CONFIG_PATH}"
export ENCHANT_CFLAGS="-I/usr/include/enchant-2"
export ENCHANT_LIBS="-L/usr/lib/x86_64-linux-gnu -lenchant-2"
export GDLIB_CFLAGS="-I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include"
export GDLIB_LIBS="-L${libdir} -lglib-2.0"

./configure \
  --prefix=${PREFIX_PHP} \
  --bindir="${PREFIX_PHP}"/bin \
  --sbindir="${PREFIX_PHP}"/sbin \
  --with-config-file-path="${PREFIX_PHP}"/etc \
  --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
  --disable-cgi \
  --with-fpm-user=www \
  --with-fpm-group=www \
  --enable-bcmath \
  --enable-calendar \
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
  --with-bz2 \
  --with-curl \
  --with-enchant \
  --with-external-gd \
  --with-external-pcre \
  --with-ffi \
  --with-freetype \
  --with-gettext \
  --with-gmp \
  --with-imap \
  --with-imap-ssl \
  --with-jpeg \
  --with-kerberos \
  --with-iconv \
  --with-ldap \
  --with-mhash \
  --with-mysqli \
  --with-pcre-jit \
  --with-pdo-mysql \
  --with-pdo-pgsql \
  --with-pgsql \
  --with-pic \
  --with-pspell \
  --with-readline \
  --with-snmp \
  --with-sodium \
  --with-tidy \
  --with-webp \
  --with-xpm \
  --with-zip \
  --with-zlib

make -j ${CORES}
make install

mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
cp php.ini* ${PREFIX_PHP}/etc/
cp php.ini-development ${PREFIX_PHP}/etc/php.ini

# --with-openssl \
# --with-xmlrpc \
# --with-expat \
# --with-xsl \
