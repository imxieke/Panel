#!/usr/bin/env bash
# @Author: imxieke
# @Date:   2021-10-18 10:17:55
# @Last Modified by:   imxieke
# @Last Modified time: 2021-10-18 10:19:59

LIST=$(cat panel/data/list.json  | jq | grep shell | awk -F '"' '{print $4}')
cd exts

for ext in ${LIST}; do
	echo $ext
	wget -c http://dg1.bt.cn/install/0/$ext
done