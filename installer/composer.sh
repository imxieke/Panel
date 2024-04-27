#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2023-10-15 18:35:38
 # @LastEditTime: 2023-10-15 18:39:20
 # @LastEditors: Cloudflying
 # @Description: Install Latest Version Composer
### 

if [[ -z "$(command -v composer)" ]]; then
    wget -cq --no-check-certificate https://mirrors.aliyun.com/composer/composer.phar -O /usr/bin/composer
    chmod +x /usr/bin/composer
	composer config -g repos.packagist composer https://mirrors.cloud.tencent.com/composer
fi