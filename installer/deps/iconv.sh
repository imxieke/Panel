#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2024-04-27 10:00:06
# @LastEditTime: 2024-04-27 10:01:17
# @LastEditors: Cloudflying
# @Description: Compile Install libiconv
###

VERSION='1.17'

wget -c https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${VERSION}.tar.gz -O /tmp/libiconv-${VERSION}.tar.gz

mkdir -p /build/src
tar -xvf /tmp/libiconv-${VERSION}.tar.gz -C /tmp/src
cd libiconv-${VERSION} || exit 1
./configure --prefix=/usr
make -j8
make install
