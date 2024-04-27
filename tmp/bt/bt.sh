#!/usr/bin/env bash
###
 # @Author: Cloudflying
 # @Date: 2023-09-08 23:30:37
 # @LastEditTime: 2023-09-09 01:27:34
 # @LastEditors: Cloudflying
 # @Description: BT Panel 获取资源脚本
### 

URL="https://hk1-node.bt.cn"

# /install/conf/softList.conf

# 0 1 3 4 5
# not found 2
mtype=7

_fetch()
{
	wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36" $@
}
# _fetch ${URL}/install/${mtype}/lib.sh -O lib-${mtype}.sh

cd plugins

# plugins=("nginx oneav rsync")
# cat plug*.json | grep '"name"' | awk -F ':' '{print $2}'  | sed 's#"##g' | sed 's#,##g' | sort | uniq > plug.txt

# nginx.sh

for plug in $(cat ../plug.txt)
do
	mkdir -p ${plug} && cd ${plug}
	if [[ ! -f "${plug}.sh" ]]; then
		_fetch "https://download.bt.cn/install/plugin/${plug}/install.sh" -O ${plug}.sh
	fi
	cd ../
	sleep 1
done

https://download.bt.cn/install/plugin/btwaf/install.sh
