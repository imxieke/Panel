#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2024-04-27 10:00:06
# @LastEditTime: 2024-04-27 10:01:17
# @LastEditors: Cloudflying
# @Description: Compile Install libiconv
###

wget -c https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz -O /tmp/libiconv-1.17.tar.gz

mkdir -p /build/src
tar -xvf /tmp/libiconv-1.17.tar.gz -C /tmp/src
cd libiconv-1.17 || exit 1
./configure --prefix=/usr
make -j8
make install
