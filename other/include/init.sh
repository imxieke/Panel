#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2023-11-01 21:50:32
 # @LastEditTime: 2023-11-01 21:55:02
 # @LastEditors: Cloudflying
 # @Description: Init Server
### 

# sed -i "s#archive.ubuntu.com#mirrors.aliyun.com#g" /etc/apt/sources.list
apt install -y wget curl unzip
apt install -y build-essential autoconf automake