#!/usr/bin/env bash
# @Author: imxieke
# @Date:   2021-10-18 10:07:52
# @Last Modified by:   imxieke
# @Last Modified time: 2021-10-18 10:11:23

EXTS=$(cat panel/data/phplib.* | jq | grep shell | sort | uniq | awk -F '"' '{print $4}')

cd php-exts

for ext in ${EXTS}; do
	echo $ext
	wget -c http://dg1.bt.cn/install/0/$ext
done