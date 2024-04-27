#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-11-01 21:50:32
# @LastEditTime: 2024-04-27 14:09:59
# @LastEditors: Cloudflying
# @Description: Init Server
###

# sed -i "s#archive.ubuntu.com#mirrors.aliyun.com#g" /etc/apt/sources.list
# sed -i "s#deb.debian.org#mirrors.aliyun.com#g" /etc/apt/sources.list.d/debian.sources
apt install -y wget curl unzip
apt install -y build-essential autoconf automake pkg-config

# oniguruma libonig-dev
# amqp librabbitmq-dev
# event libevent-dev
# gmagick libgraphicsmagick1-dev
# gnupg libgpgme-dev
# imagick libmagickwand-dev
# leveldb libleveldb-dev
sqlsrv freetds-dev
# mssql
# libzookeeper-st-dev

# PHP 8.1+ Deps
apt install -y \
  libxml2-dev \
  libssl-dev \
  libsqlite3-dev \
  libkrb5-dev \
  librabbitmq-dev \
  libevent-dev \
  libgraphicsmagick1-dev \
  libgpgme-dev \
  libmagickwand-dev \
  libleveldb-dev \
  libmcrypt-dev \
  libmemcached-dev \
  librdkafka-dev \
  libsmbclient-dev \
  libssh2-1-dev \
  libyaml-dev \
  libzookeeper-mt-dev \
  libffi-dev \
  libonig-dev \
  libsqlite3-dev \
  libcurl4-openssl-dev \
  libreadline-dev \
  libgmp-dev \
  librecode-dev \
  libmcrypt-dev \
  libmsgpack-dev \
  libpspell-dev \
  libpq-dev \
  libxml2-dev \
  libsodium-dev \
  libxslt1-dev \
  libzip-dev \
  libtidy-dev \
  libssl-dev \
  libsnmp-dev \
  libldap-dev \
  libbison-dev \
  libxpm-dev \
  libjpeg-dev \
  libwebp-dev \
  libmagic-dev \
  libbrotli-dev \
  libzstd-dev \
  libldap-dev \
  zlib1g-dev \
  libenchant-2-dev \
  libglib2.0-dev \
  libgd-dev \
  libc-client2007e-dev \
  unixodbc-dev \
  freetds-dev

# Nginx Deps
apt install -y libgeoip-dev
