#!/usr/bin/env bash
###
# @Author: Cloudflying
# @Date: 2023-10-15 20:52:54
# @LastEditTime: 2023-10-15 21:10:52
# @LastEditors: Cloudflying
# @Description: Install ionCube for PHP, But Not Support PHP 8.0
###

# example ver variable 5.6 7.4 8.1
VER=$1

_fetch() {
    mkdir -p /tmp/boxs-php-temp
    cd /tmp/boxs-php-temp || exit 1
    wget https://github.com/dockenv/dockenv-images/releases/download/ioncube/ioncube_loaders_lin_x86-64.tar.gz -O ioncube.tar.gz
    tar -xvf ioncube.tar.gz
}

_upgrade() {
    # fetch ionCube Version
    now_ver=$(php -v | grep -i 'ioncube' | awk -F ' ' '{print $6}' | sed "s#v##g" | sed "s#,##g")
    echo "${now_ver}"
}

_uninstall() {
    rm -fr "php_config.ini"
}

# 不支持 80
case "$VER" in
56 | 70 | 71 | 72 | 73 | 74 | 81 | 82)
    cp -fr /tmp/boxs-php-temp/ioncube_loader_lin_${VER}.so /usr/lib/php/xxx/conf.d/001-ioncube.ini
    ;;
*)
    echo "UnSupport Your PHP Version ${VER}"
    ;;
esac
