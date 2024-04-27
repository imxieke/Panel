#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-09-08 22:52:16
# @LastEditTime: 2024-04-27 15:46:21
# @LastEditors: Cloudflying
# @Description: Nginx Compile
###

NGINX_VER="1.26.0"
MIRRORS="https://mirrors.xie.ke/pkgs"
URL="${MIRRORS}/nginx/nginx-${NGINX_VER}.tar.gz"
DOCKENV_PREFIX="/usr/local/dockenv"
NGINX_PREFIX=${DOCKENV_PREFIX}/nginx

mkdir -p /tmp/build/nginx
mkdir -p /tmp/src

if [[ ! -f "/tmp/src/nginx-${NGINX_VER}.tar.gz" ]]; then
  echo "==> Fetch Nginx Source Code"
  wget -c ${URL} -O /tmp/src/nginx-${NGINX_VER}.tar.gz
fi

if [[ ! -f "/tmp/build/nginx/nginx-${NGINX_VER}/configure" ]]; then
  echo "==> DeCompress Nginx Source Code"
  tar -xvf /tmp/src/nginx-${NGINX_VER}.tar.gz -C /tmp/build/nginx
fi

cd /tmp/build/nginx/nginx-${NGINX_VER} || exit 1

# 使 Nginx 可以直接使用本地已安装 openssl

if [[ -n "$(grep '\.openssl' auto/lib/openssl/conf)" ]]; then
  sed -i 's/\.openssl\///g' auto/lib/openssl/conf
  sed -i 's/libssl\.a/x86_64-linux-gnu\/libssl\.a/g' auto/lib/openssl/conf
  sed -i 's/libcrypto\.a/x86_64-linux-gnu\/libcrypto\.a/g' auto/lib/openssl/conf
fi

./configure \
  --prefix=${NGINX_PREFIX} \
  --sbin-path=${NGINX_PREFIX}/sbin/nginx \
  --modules-path=${NGINX_PREFIX}/modules \
  --conf-path=${NGINX_PREFIX}/nginx.conf \
  --pid-path=${NGINX_PREFIX}/nginx.pid \
  --lock-path=${NGINX_PREFIX}/nginx.lock \
  --http-client-body-temp-path=${NGINX_PREFIX}/tmp/client_body \
  --http-log-path=${NGINX_PREFIX}/log/nginx.log \
  --error-log-path=${NGINX_PREFIX}/log/nginx.err.log \
  --http-proxy-temp-path=${NGINX_PREFIX}/tmp/proxy \
  --http-fastcgi-temp-path=${NGINX_PREFIX}/tmp/fastcgi \
  --http-uwsgi-temp-path=${NGINX_PREFIX}/tmp/uwsgi \
  --http-scgi-temp-path=${NGINX_PREFIX}/tmp/scgi \
  --user=nginx \
  --group=nginx \
  --with-compat \
  --with-file-aio \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_degradation_module \
  --with-http_flv_module \
  --with-http_geoip_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_image_filter_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-http_xslt_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-stream \
  --with-stream_geoip_module \
  --with-stream_realip_module \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-threads \
  --with-pcre \
  --with-poll_module \
  --with-pcre-jit \
  --with-select_module \
  --with-openssl=/usr \
  --add-dynamic-module=modules/ngx_brotli \
  --add-dynamic-module=modules/nginx-http-flv-module \
  --add-dynamic-module=modules/nginx-vod-module

make $(nproc)
make install
