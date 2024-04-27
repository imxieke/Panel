#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-09-08 22:52:34
# @LastEditTime: 2024-04-27 00:19:35
# @LastEditors: Cloudflying
# @Description:
###

MIRRORS="https://mirrors.xie.ke/pkgs/php/"
PHP_VER="5.6.40"
URL=${MIRRORS}"/php-${PHP_VER}.tar.gz"
PHP_PREFIX="/usr/local/dockenv"
mkdir -p /tmp/.build && cd /tmp/.build || exit 1

if [[ ! -f "/tmp/.build/php-${PHP_VER}.tar.gz" ]]; then
  echo "Fetch ${PHP_VER} Source Code"
  wget ${URL} -O /tmp/.build/php-${PHP_VER}.tar.gz
fi

if [[ ! -d "/tmp/.build/php-${PHP_VER}" ]]; then
  tar -xvf /tmp/.build/php-${PHP_VER}.tar.gz -C /tmp/.build >/dev/null 2>&1
fi

cd /tmp/.build/php-"${PHP_VER}" || exit 1
exit 0

VER=$1
PHP_VER=$(eval echo \$"PHP${VER}_VER")
URL=${MIRRORS}"/php/php-${PHP_VER}.tar.gz"
mkdir -p /tmp/.build && cd /tmp/.build
echo "Fetch ${PHP_VER} Source Code"
wget -c ${URL} >/dev/null 2>&1 && tar -xvf php-${PHP_VER}.tar.gz >/dev/null 2>&1 && cd php-${PHP_VER}
PREFIX_PHP=${PREFIX}/php/${VER}
mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}

ENABLE_OPENSSL=''
if [[ -z "$(grep 'VERSION_ID="2' /etc/os-release)" ]]; then
  ENABLE_OPENSSL='--with-openssl'
fi

./configure \
  --prefix=${PREFIX_PHP} \
  --bindir="${PREFIX_PHP}"/bin \
  --sbindir="${PREFIX_PHP}"/sbin \
  --with-config-file-path="${PREFIX_PHP}"/etc \
  --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d \
  --with-fpm-user=www \
  --with-fpm-group=www \
  --enable-bcmath \
  --enable-calendar \
  --enable-exif \
  --enable-fpm \
  --enable-inline-optimization \
  --enable-mbregex \
  --enable-mbstring \
  --enable-mysqlnd \
  --enable-pcntl \
  --enable-shmop \
  --enable-soap \
  --enable-sockets \
  --enable-sysvsem \
  --enable-wddx \
  --enable-zip \
  --with-bz2 \
  --with-curl \
  --with-enchant \
  --with-gettext \
  --with-gmp \
  --with-iconv \
  --with-jpeg-dir \
  --with-libxml-dir \
  --with-libzip \
  --with-mcrypt \
  --with-mhash \
  --with-mysql=mysqlnd \
  --with-mysqli=mysqlnd \
  --with-kerberos \
  --with-pcre-jit \
  --with-pdo-mysql=mysqlnd \
  --with-pdo-pgsql \
  --with-pic \
  --with-pgsql \
  --with-png-dir \
  --with-recode \
  --with-readline \
  --with-regex \
  --with-tidy \
  --with-xmlrpc \
  --with-xsl \
  --with-zlib \
  --without-pear \
  --disable-fileinfo \
  --disable-rpath $ENABLE_OPENSSL
make -j${CORES}
make install
cp php.ini* ${PREFIX_PHP}/etc/
mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
cp php.ini-development ${PREFIX_PHP}/etc/php.ini
# 没什么卵用
# --with-mssql
