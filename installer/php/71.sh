#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-09-08 22:52:39
# @LastEditTime: 2024-04-26 22:09:10
# @LastEditors: Cloudflying
# @Description:
###

URL=${MIRRORS}"/php/php-${PHP71_VER}.tar.gz"
mkdir -p /tmp/.build && cd /tmp/.build
wget -c ${URL} >/dev/null 2>&1 && tar -xvf php-${PHP71_VER}.tar.gz >/dev/null 2>&1 && cd php-${PHP71_VER}
PREFIX_PHP=${PREFIX}/php/71
mkdir -p ${PREFIX_PHP}/{bin,sbin,etc,conf.d}
./configure --prefix=${PREFIX_PHP} --bindir="${PREFIX_PHP}"/bin --sbindir="${PREFIX_PHP}"/sbin --with-config-file-path="${PREFIX_PHP}"/etc --with-config-file-scan-dir="${PREFIX_PHP}"/conf.d --with-fpm-user=www --with-fpm-group=www --enable-bcmath --enable-calendar --enable-exif --enable-fpm --enable-ftp --enable-mbregex --enable-mbstring --enable-mysqlnd --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-wddx --enable-zip --with-bz2 --with-curl --with-enchant --with-webp-dir --with-jpeg-dir --with-png-dir --with-gettext --with-gmp --with-iconv --with-libxml-dir --with-libzip --with-mcrypt --with-mhash --with-mysqli=mysqlnd --with-openssl --with-kerberos --with-pdo-mysql=mysqlnd --with-pdo-pgsql --with-pic --with-pgsql --with-pspell --with-png-dir --with-recode --with-readline --with-tidy --with-xmlrpc --with-xsl --with-zlib --without-pear
make -j${CORES}
make install
mv ${PREFIX_PHP}/etc/php-fpm.conf.default ${PREFIX_PHP}/etc/php-fpm.conf
cp php.ini* ${PREFIX_PHP}/etc/
cp php.ini-development ${PREFIX_PHP}/etc/php.ini
# --enable-dmalloc \
